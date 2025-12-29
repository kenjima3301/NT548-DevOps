#!/bin/bash
set -e

echo "🔍 Validating Kustomize configurations..."
echo ""

# Check if kustomize is installed
if ! command -v kustomize &> /dev/null; then
    echo "❌ Error: kustomize is not installed"
    echo "Install with: curl -s 'https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh' | bash"
    exit 1
fi

echo "✓ Kustomize version: $(kustomize version --short)"
echo ""

# Validate base
echo "📦 Validating base configuration..."
if kustomize build ci-cd/k8s/base > /dev/null 2>&1; then
    echo "✅ Base configuration is valid"
else
    echo "❌ Base configuration has errors"
    kustomize build ci-cd/k8s/base
    exit 1
fi
echo ""

# Validate each overlay
for env in dev staging production; do
    echo "📦 Validating $env overlay..."
    
    if [ ! -d "ci-cd/k8s/overlays/$env" ]; then
        echo "⚠️  Warning: $env overlay not found, skipping"
        continue
    fi
    
    if kustomize build ci-cd/k8s/overlays/$env > /dev/null 2>&1; then
        echo "✅ $env overlay is valid"
        
        # Show resource count
        RESOURCE_COUNT=$(kustomize build ci-cd/k8s/overlays/$env | grep -c "^kind:")
        echo "   └─ Resources: $RESOURCE_COUNT"
    else
        echo "❌ $env overlay has errors"
        kustomize build ci-cd/k8s/overlays/$env
        exit 1
    fi
    echo ""
done

echo "🎉 All Kustomize configurations are valid!"
