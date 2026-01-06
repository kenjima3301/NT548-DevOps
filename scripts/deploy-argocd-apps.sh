#!/bin/bash
set -e

echo "🚀 Deploying ArgoCD Applications..."
echo ""

# Find project root directory (where ci-cd folder exists)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📂 Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

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
else
    echo "  ⚠️  dorashop-dev.yaml not found"
fi

if [ -f "ci-cd/argocd/dorashop-staging.yaml" ]; then
    echo "  → Applying dorashop-staging..."
    kubectl apply -f ci-cd/argocd/dorashop-staging.yaml
else
    echo "  ⚠️  dorashop-staging.yaml not found"
fi

if [ -f "ci-cd/argocd/dorashop-production.yaml" ]; then
    echo "  → Applying dorashop-production..."
    kubectl apply -f ci-cd/argocd/dorashop-production.yaml
else
    echo "  ⚠️  dorashop-production.yaml not found"
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
echo ""

# Wait for services and update access_info.txt if exists
ACCESS_INFO="$PROJECT_ROOT/terraform-aws-iac/envs/dev/access_info.txt"
if [ -f "$ACCESS_INFO" ]; then
    echo "⏳ Waiting for dorashop services to be ready..."
    echo ""
    
    # Wait max 5 minutes for services
    COUNTER=0
    MAX_WAIT=60
    DEV_URL=""
    STAGING_URL=""
    PROD_URL=""
    
    while [ $COUNTER -lt $MAX_WAIT ]; do
        # Check all three environments
        if [ -z "$DEV_URL" ] && kubectl get svc dev-dorashop-service -n dorashop-dev &> /dev/null; then
            DEV_URL=$(kubectl get svc dev-dorashop-service -n dorashop-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
            [ -n "$DEV_URL" ] && echo "✅ Got Dev URL: http://$DEV_URL"
        fi
        
        if [ -z "$STAGING_URL" ] && kubectl get svc staging-dorashop-service -n dorashop-staging &> /dev/null; then
            STAGING_URL=$(kubectl get svc staging-dorashop-service -n dorashop-staging -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
            [ -n "$STAGING_URL" ] && echo "✅ Got Staging URL: http://$STAGING_URL"
        fi
        
        if [ -z "$PROD_URL" ] && kubectl get svc prod-dorashop-service -n dorashop &> /dev/null; then
            PROD_URL=$(kubectl get svc prod-dorashop-service -n dorashop -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
            [ -n "$PROD_URL" ] && echo "✅ Got Production URL: http://$PROD_URL"
        fi
        
        # If all URLs are found, break
        if [ -n "$DEV_URL" ] && [ -n "$STAGING_URL" ] && [ -n "$PROD_URL" ]; then
            echo "✅ All service URLs retrieved!"
            break
        fi
        
        COUNTER=$((COUNTER + 1))
        sleep 5
        [ $((COUNTER % 6)) -eq 0 ] && echo "  Still waiting... ($COUNTER/$MAX_WAIT)"
    done
    
    # Get ArgoCD info
    ARGO_URL=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "")
    
    # Update access_info.txt with all URLs
    cat <<EOF > $ACCESS_INFO
=========================================================
✅ TRIỂN KHAI HOÀN TẤT! THÔNG TIN TRUY CẬP HỆ THỐNG:
=========================================================
🔹 ArgoCD UI:       https://$ARGO_URL
🔹 ArgoCD Username: admin
🔹 ArgoCD Password: $ARGO_PWD
---------------------------------------------------------
🔸 Dorashop Web (Dev):        http://$DEV_URL
🔸 Dorashop Web (Staging):    http://$STAGING_URL
🔸 Dorashop Web (Production): http://$PROD_URL
=========================================================
EOF
    
    echo ""
    echo "✅ Updated access_info.txt with all environment URLs"
    
    if [ $COUNTER -ge $MAX_WAIT ]; then
        echo ""
        echo "⚠️  Note: Some services may still be provisioning LoadBalancers."
        echo "   You can get URLs later with:"
        echo "   kubectl get svc -n dorashop-dev"
        echo "   kubectl get svc -n dorashop-staging"
        echo "   kubectl get svc -n dorashop"
    fi
fi
