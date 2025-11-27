#!/bin/bash

CLUSTER_NAME=$1
AWS_REGION=$2
ECR_URL=$3

if [ -z "$CLUSTER_NAME" ] || [ -z "$AWS_REGION" ] || [ -z "$ECR_URL" ]; then
  echo "❌ Lỗi: Thiếu tham số truyền vào!"
  echo "Cách dùng: ./setup_cluster.sh <CLUSTER_NAME> <REGION> <ECR_URL>"
  exit 1
fi

GIT_REPO="https://github.com/kenjima3301/NT548-DevOps.git"
APP_PATH="ci-cd/k8s"
NAMESPACE="dorashop"

echo "🔧 Cấu hình: Cluster=$CLUSTER_NAME | Region=$AWS_REGION | ECR=$ECR_URL"

echo "🚀 [1/6] Cập nhật Kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "🚀 [2/6] Tạo Namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 [3/6] Tạo Secret cho ECR (regcred)..."
TOKEN=$(aws ecr get-login-password --region $AWS_REGION)
kubectl delete secret regcred -n $NAMESPACE --ignore-not-found
kubectl create secret docker-registry regcred \
  --docker-server=$ECR_URL \
  --docker-username=AWS \
  --docker-password=$TOKEN \
  --namespace=$NAMESPACE

echo "🚀 [4/6] Cài đặt ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Đang chờ ArgoCD khởi động (Đợi 60s)..."
sleep 60
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo "🚀 [5/6] Patch LoadBalancer cho ArgoCD..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "🚀 [6/6] Khai báo App với ArgoCD (GitOps)..."
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: dorashop
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $GIT_REPO
    targetRevision: HEAD
    path: $APP_PATH
  destination:
    server: https://kubernetes.default.svc
    namespace: $NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "✅ HOÀN TẤT! Cluster đã sẵn sàng."