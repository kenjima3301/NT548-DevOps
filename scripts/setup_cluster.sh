#!/bin/bash

# --- CẤU HÌNH BIẾN ---
CLUSTER_NAME=$1
AWS_REGION=$2
ECR_URL=$3

# Đường dẫn tới thư mục chứa Terraform State (quan trọng để lấy tên S3)
TF_DIR="terraform-aws-iac/envs/dev"

# Đường dẫn tới thư mục chứa ảnh mẫu (Seeding Data)
MEDIA_SOURCE="web/dorashop/media" 

GIT_REPO="https://github.com/kenjima3301/NT548-DevOps.git"
APP_PATH="ci-cd/k8s"
NAMESPACE="dorashop"

# --- KIỂM TRA ĐẦU VÀO ---
if [ -z "$CLUSTER_NAME" ] || [ -z "$AWS_REGION" ] || [ -z "$ECR_URL" ]; then
  echo "❌ Lỗi: Thiếu tham số truyền vào!"
  echo "Cách dùng: ./setup_cluster.sh <CLUSTER_NAME> <REGION> <ECR_URL>"
  exit 1
fi

echo "🔧 Cấu hình: Cluster=$CLUSTER_NAME | Region=$AWS_REGION | ECR=$ECR_URL"

# --- 1. KUBECONFIG ---
echo "🚀 [1/7] Cập nhật Kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# --- 2. NAMESPACE ---
echo "🚀 [2/7] Tạo Namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl delete sc gp2 --ignore-not-found

# --- 3. ECR SECRET ---
echo "🚀 [3/7] Tạo Secret cho ECR (regcred)..."
TOKEN=$(aws ecr get-login-password --region $AWS_REGION)
kubectl delete secret regcred -n $NAMESPACE --ignore-not-found
kubectl create secret docker-registry regcred \
  --docker-server=$ECR_URL \
  --docker-username=AWS \
  --docker-password=$TOKEN \
  --namespace=$NAMESPACE

# --- 4. ARGOCD INSTALL ---
echo "🚀 [4/7] Cài đặt ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Đang chờ ArgoCD khởi động (Đợi 60s)..."
sleep 60
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# --- 5. ARGOCD LB ---
echo "🚀 [5/7] Patch LoadBalancer cho ArgoCD..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# --- 6. ARGOCD APP ---
echo "🚀 [6/7] Khai báo App với ArgoCD (GitOps)..."
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

# --- 7. SYNC S3 (SEEDING DATA) ---
echo "🚀 [7/7] Đồng bộ dữ liệu mẫu lên S3..."

# Kiểm tra xem thư mục Terraform có tồn tại không
if [ ! -d "$TF_DIR" ]; then
    echo "⚠️ Cảnh báo: Không tìm thấy thư mục Terraform tại $TF_DIR. Bỏ qua bước sync S3."
else
    BUCKET_NAME=$(terraform -chdir=$TF_DIR output -raw media_bucket_name)

    if [ -z "$BUCKET_NAME" ]; then
        echo "❌ Lỗi: Không lấy được tên Bucket từ Terraform output. Kiểm tra lại code Terraform."
    else
        echo "✅ Detected Bucket: $BUCKET_NAME"
        
        if [ -d "$MEDIA_SOURCE" ]; then
            echo "🔄 Đang upload ảnh từ $MEDIA_SOURCE lên S3..."
            # Sync và set quyền public-read
            aws s3 sync $MEDIA_SOURCE s3://$BUCKET_NAME/ --acl public-read
            echo "✅ Upload hoàn tất!"
        else
            echo "⚠️ Cảnh báo: Không tìm thấy thư mục ảnh mẫu tại $MEDIA_SOURCE. S3 sẽ trống rỗng."
        fi
    fi
fi

echo "🎉 HOÀN TẤT! Cluster đã sẵn sàng."