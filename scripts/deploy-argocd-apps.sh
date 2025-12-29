#!/bin/bash
set -e

echo "🚀 Deploying ArgoCD Applications..."
echo ""

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: kubectl is not configured or cluster is not accessible"
    exit 1
fi

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ Error: ArgoCD namespace not found"
    echo "Install ArgoCD first with:"
    echo "  kubectl create namespace argocd"
    echo "  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

echo "✓ ArgoCD namespace found"
echo ""

# Deploy applications
echo "📦 Deploying ArgoCD Applications..."

if [ -f "ci-cd/argocd/dorashop-dev.yaml" ]; then
    echo "  → Applying dorashop-dev..."
    kubectl apply -f ci-cd/argocd/dorashop-dev.yaml
fi

if [ -f "ci-cd/argocd/dorashop-staging.yaml" ]; then
    echo "  → Applying dorashop-staging..."
    kubectl apply -f ci-cd/argocd/dorashop-staging.yaml
fi

if [ -f "ci-cd/argocd/dorashop-production.yaml" ]; then
    echo "  → Applying dorashop-production..."
    kubectl apply -f ci-cd/argocd/dorashop-production.yaml
fi

echo ""
echo "✅ ArgoCD Applications deployed successfully!"
echo ""
echo "🔍 Check application status:"
echo "   kubectl get applications -n argocd"
echo ""
echo "📊 View in ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then open: https://localhost:8080"
echo ""
echo "🔑 Get initial admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
