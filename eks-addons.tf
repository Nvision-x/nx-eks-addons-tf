locals {
  autoscaler_labels = {
    "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
    "k8s-app"   = "cluster-autoscaler"
  }

  # ServiceAccount YAML with IRSA annotation
  sa_yaml_irsa = <<-EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: ${var.autoscaler_service_account}
  namespace: ${var.namespace}
  annotations:
    eks.amazonaws.com/role-arn: ${var.cluster_autoscaler_role_arn}
EOF

  # ServiceAccount YAML without IRSA annotation (for Pod Identity)
  sa_yaml_pod_identity = <<-EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
  name: ${var.autoscaler_service_account}
  namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "service_account" {
  yaml_body = var.enable_irsa ? local.sa_yaml_irsa : local.sa_yaml_pod_identity
}

resource "kubectl_manifest" "role" {
  yaml_body = <<-EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${var.autoscaler_role_name}
  namespace: ${var.namespace}
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "list", "watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs: ["delete", "get", "update", "watch"]
EOF
}

resource "kubectl_manifest" "role_binding" {
  depends_on = [
    kubectl_manifest.service_account,
    kubectl_manifest.role
  ]
  
  yaml_body = <<-EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${var.autoscaler_role_name}
  namespace: ${var.namespace}
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${var.autoscaler_role_name}
subjects:
  - kind: ServiceAccount
    name: ${var.autoscaler_service_account}
    namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "cluster_role" {
  yaml_body = <<-EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${var.autoscaler_role_name}
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
rules:
  - apiGroups: [""]
    resources: ["events", "endpoints"]
    verbs: ["create", "patch"]
  - apiGroups: [""]
    resources: ["pods/eviction"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["pods/status"]
    verbs: ["update"]
  - apiGroups: [""]
    resources: ["endpoints"]
    resourceNames: ["cluster-autoscaler"]
    verbs: ["get", "update"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["watch", "list", "get", "update"]
  - apiGroups: [""]
    resources:
      - "namespaces"
      - "pods"
      - "services"
      - "replicationcontrollers"
      - "persistentvolumeclaims"
      - "persistentvolumes"
    verbs: ["watch", "list", "get"]
  - apiGroups: ["extensions"]
    resources: ["replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: ["watch", "list"]
  - apiGroups: ["apps"]
    resources: ["statefulsets", "replicasets", "daemonsets"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities", "volumeattachments"]
    verbs: ["watch", "list", "get"]
  - apiGroups: ["batch", "extensions"]
    resources: ["jobs"]
    verbs: ["get", "list", "watch", "patch"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["create"]
  - apiGroups: ["coordination.k8s.io"]
    resourceNames: ["cluster-autoscaler"]
    resources: ["leases"]
    verbs: ["get", "update"]
EOF
}

resource "kubectl_manifest" "cluster_role_binding" {
  depends_on = [
    kubectl_manifest.service_account,
    kubectl_manifest.cluster_role
  ]
  
  yaml_body = <<-EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${var.autoscaler_role_name}
  labels:
    k8s-addon: cluster-autoscaler.addons.k8s.io
    k8s-app: cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${var.autoscaler_role_name}
subjects:
  - kind: ServiceAccount
    name: ${var.autoscaler_service_account}
    namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "deployment" {
  depends_on = [
    kubectl_manifest.service_account,
    kubectl_manifest.cluster_role,
    kubectl_manifest.cluster_role_binding
  ]
  
  yaml_body = <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cluster-autoscaler
  namespace: ${var.namespace}
  labels:
    app: cluster-autoscaler
spec:
  replicas: ${var.autoscaler_replicas}
  selector:
    matchLabels:
      app: cluster-autoscaler
  template:
    metadata:
      labels:
        app: cluster-autoscaler
    spec:
      priorityClassName: system-cluster-critical
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        fsGroup: 65534
      serviceAccountName: ${var.autoscaler_service_account}
      containers:
        - image: registry.k8s.io/autoscaling/cluster-autoscaler:${var.cluster_autoscaler_version}
          name: cluster-autoscaler
          resources:
            limits:
              cpu: ${var.autoscaler_resources.limits.cpu}
              memory: ${var.autoscaler_resources.limits.memory}
            requests:
              cpu: ${var.autoscaler_resources.requests.cpu}
              memory: ${var.autoscaler_resources.requests.memory}
          command:
            - ./cluster-autoscaler
            - --v=${var.autoscaler_log_level}
            - --stderrthreshold=info
            - --cloud-provider=aws
            - --skip-nodes-with-local-storage=${var.autoscaler_skip_nodes_with_local_storage}
            - --expander=${var.autoscaler_expander}
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}
EOF
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = var.lb_controller_role_name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.namespace
  version    = var.lb_controller_chart_version

  # Helm 3.x syntax - set as list
  set = concat([
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = var.lb_controller_service_account
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ],
  # Only add IRSA annotation when enable_irsa is true
  # For Pod Identity, no annotation is needed
  var.enable_irsa ? [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.lb_controller_role_arn
    }
  ] : [])
}


