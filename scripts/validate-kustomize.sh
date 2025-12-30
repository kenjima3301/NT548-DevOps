#!/bin/bash
set -e

echo "🔍 Validating Kustomize configurations..."
echo ""

if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl is not installed"
    exit 1
fi

KUSTOMIZE_VERSION=$(kubectl version --client -o json | grep -o '"gitVersion": "[^"]*"' | head -1)
echo "✓ Using built-in Kustomize within kubectl"
echo ""

echo "📦 Validating base configuration..."
if kubectl kustomize ci-cd/k8s/base > /dev/null 2>&1; then
    echo "✅ Base configuration is valid"
else
    echo "❌ Base configuration has errors"
    kubectl kustomize ci-cd/k8s/base
    exit 1
fi
echo ""

for env in dev staging production; do
    echo "📦 Validating $env overlay..."
    
    if [ ! -d "ci-cd/k8s/overlays/$env" ]; then
        echo "⚠️  Warning: $env overlay not found, skipping"
        continue
    fi
    
    if kubectl kustomize ci-cd/k8s/overlays/$env > /dev/null 2>&1; then
        echo "✅ $env overlay is valid"
        
        RESOURCE_COUNT=$(kubectl kustomize ci-cd/k8s/overlays/$env | grep -c "^kind:")
        echo "   └─ Resources: $RESOURCE_COUNT"
    else
        echo "❌ $env overlay has errors"
        kubectl kustomize ci-cd/k8s/overlays/$env
        exit 1
    fi
    echo ""
done

echo "🎉 All Kustomize configurations are valid!"