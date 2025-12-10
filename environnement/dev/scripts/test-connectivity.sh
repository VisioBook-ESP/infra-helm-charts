#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="/tmp/connectivity-reports"
mkdir -p "$OUTPUT_DIR"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local service_name=$1
    local url=$2
    local timeout=${3:-5}

    echo "Testing $service_name..."

    # Faire le curl et capturer les métriques
    response=$(curl -s -o /tmp/response_body.txt -w "%{http_code}|%{time_total}|%{time_namelookup}|%{time_connect}" \
                    --max-time $timeout "$url" 2>&1)

    http_code=$(echo $response | cut -d'|' -f1)
    time_total=$(echo $response | cut -d'|' -f2)
    time_dns=$(echo $response | cut -d'|' -f3)
    time_connect=$(echo $response | cut -d'|' -f4)
    response_body=$(cat /tmp/response_body.txt 2>/dev/null)

    # Déterminer le status
    if [ "$http_code" = "000" ] || [ -z "$http_code" ]; then
        status="ERROR"
        status_class="error"
        http_code="Connection Failed"
    elif [ "$http_code" = "200" ]; then
        status="OK"
        status_class="success"
    elif [ "$http_code" = "503" ]; then
        status="DEGRADED"
        status_class="warning"
    else
        status="WARNING"
        status_class="warning"
    fi

    # Retourner les résultats en JSON-like format
    echo "$status|$status_class|$http_code|$time_total|$time_dns|$time_connect|$response_body"
}

# Fonction pour générer le HTML
generate_html() {
    local source_service=$1
    local source_namespace=$2
    local output_file=$3
    shift 3
    local -n services=$1

    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connectivity Report - SOURCE_SERVICE</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }

        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .header .subtitle {
            font-size: 1.2em;
            opacity: 0.9;
        }

        .header .timestamp {
            margin-top: 15px;
            font-size: 0.9em;
            opacity: 0.8;
        }

        .summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px 40px;
            background: #f8f9fa;
            border-bottom: 2px solid #e0e0e0;
        }

        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }

        .summary-card:hover {
            transform: translateY(-5px);
        }

        .summary-card .number {
            font-size: 2.5em;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .summary-card .label {
            color: #666;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .summary-card.total .number { color: #667eea; }
        .summary-card.success .number { color: #28a745; }
        .summary-card.warning .number { color: #ffc107; }
        .summary-card.error .number { color: #dc3545; }

        .content {
            padding: 40px;
        }

        .service-test {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            transition: all 0.3s;
        }

        .service-test:hover {
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }

        .service-test.success { border-left: 5px solid #28a745; }
        .service-test.warning { border-left: 5px solid #ffc107; }
        .service-test.error { border-left: 5px solid #dc3545; }

        .service-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .service-name {
            font-size: 1.5em;
            font-weight: bold;
            color: #333;
        }

        .status-badge {
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .status-badge.success {
            background: #d4edda;
            color: #155724;
        }

        .status-badge.warning {
            background: #fff3cd;
            color: #856404;
        }

        .status-badge.error {
            background: #f8d7da;
            color: #721c24;
        }

        .service-url {
            color: #667eea;
            font-family: 'Courier New', monospace;
            background: #f8f9fa;
            padding: 10px 15px;
            border-radius: 5px;
            margin-bottom: 15px;
            word-break: break-all;
        }

        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .metric {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }

        .metric-label {
            color: #666;
            font-size: 0.85em;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .metric-value {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
        }

        .response-body {
            background: #282c34;
            color: #abb2bf;
            padding: 20px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            max-height: 300px;
            overflow-y: auto;
        }

        .response-body pre {
            margin: 0;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        .collapsible {
            cursor: pointer;
            user-select: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #667eea;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .collapsible:hover {
            color: #764ba2;
        }

        .collapsible::before {
            content: '▼';
            transition: transform 0.3s;
        }

        .collapsible.collapsed::before {
            transform: rotate(-90deg);
        }

        .collapsible-content {
            max-height: 500px;
            overflow: hidden;
            transition: max-height 0.3s ease-out;
        }

        .collapsible-content.collapsed {
            max-height: 0;
        }

        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            border-top: 2px solid #e0e0e0;
        }

        @media (max-width: 768px) {
            .header h1 {
                font-size: 1.8em;
            }

            .service-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .metrics {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔌 Connectivity Report</h1>
            <div class="subtitle">Source: <strong>SOURCE_SERVICE</strong> (NAMESPACE_SOURCE)</div>
            <div class="timestamp">Generated: TIMESTAMP_PLACEHOLDER</div>
        </div>

        <div class="summary">
            <div class="summary-card total">
                <div class="number" id="total-count">0</div>
                <div class="label">Total Tests</div>
            </div>
            <div class="summary-card success">
                <div class="number" id="success-count">0</div>
                <div class="label">Successful</div>
            </div>
            <div class="summary-card warning">
                <div class="number" id="warning-count">0</div>
                <div class="label">Degraded</div>
            </div>
            <div class="summary-card error">
                <div class="number" id="error-count">0</div>
                <div class="label">Failed</div>
            </div>
        </div>

        <div class="content">
            <div id="test-results">
                <!-- Results will be inserted here -->
            </div>
        </div>

        <div class="footer">
            <p>Generated by Visiobook Connectivity Test Suite</p>
            <p style="margin-top: 5px; font-size: 0.9em;">Kubernetes Service Mesh Connectivity Report</p>
        </div>
    </div>

    <script>
        // Toggle collapsible sections
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('collapsible')) {
                e.target.classList.toggle('collapsed');
                const content = e.target.nextElementSibling;
                content.classList.toggle('collapsed');
            }
        });

        // Update summary counts
        function updateSummary() {
            const total = document.querySelectorAll('.service-test').length;
            const success = document.querySelectorAll('.service-test.success').length;
            const warning = document.querySelectorAll('.service-test.warning').length;
            const error = document.querySelectorAll('.service-test.error').length;

            document.getElementById('total-count').textContent = total;
            document.getElementById('success-count').textContent = success;
            document.getElementById('warning-count').textContent = warning;
            document.getElementById('error-count').textContent = error;
        }

        // Call on page load
        updateSummary();
    </script>
</body>
</html>
EOF

    # Remplacer les placeholders
    sed -i "s/SOURCE_SERVICE/$source_service/g" "$output_file"
    sed -i "s/NAMESPACE_SOURCE/$source_namespace/g" "$output_file"
    sed -i "s/TIMESTAMP_PLACEHOLDER/$TIMESTAMP/g" "$output_file"
}

# Fonction pour ajouter un résultat de test au HTML
add_test_result() {
    local output_file=$1
    local service_name=$2
    local url=$3
    local result=$4

    IFS='|' read -r status status_class http_code time_total time_dns time_connect response_body <<< "$result"

    # Formatter le temps en millisecondes
    time_total_ms=$(echo "$time_total * 1000" | bc 2>/dev/null || echo "N/A")
    time_dns_ms=$(echo "$time_dns * 1000" | bc 2>/dev/null || echo "N/A")
    time_connect_ms=$(echo "$time_connect * 1000" | bc 2>/dev/null || echo "N/A")

    # Formater le JSON si possible
    formatted_body=$(echo "$response_body" | python3 -m json.tool 2>/dev/null || echo "$response_body")

    # Échapper les caractères spéciaux pour HTML
    formatted_body=$(echo "$formatted_body" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    # Créer le HTML pour ce test
    cat >> "$output_file" << EOF
            <div class="service-test $status_class">
                <div class="service-header">
                    <div class="service-name">🎯 $service_name</div>
                    <div class="status-badge $status_class">$status</div>
                </div>

                <div class="service-url">$url</div>

                <div class="metrics">
                    <div class="metric">
                        <div class="metric-label">HTTP Status</div>
                        <div class="metric-value">$http_code</div>
                    </div>
                    <div class="metric">
                        <div class="metric-label">Total Time</div>
                        <div class="metric-value">${time_total_ms} ms</div>
                    </div>
                    <div class="metric">
                        <div class="metric-label">DNS Lookup</div>
                        <div class="metric-value">${time_dns_ms} ms</div>
                    </div>
                    <div class="metric">
                        <div class="metric-label">Connect Time</div>
                        <div class="metric-value">${time_connect_ms} ms</div>
                    </div>
                </div>

                <div class="collapsible">📄 Response Body</div>
                <div class="collapsible-content">
                    <div class="response-body">
                        <pre>$formatted_body</pre>
                    </div>
                </div>
            </div>
EOF
}

# Fonction principale pour tester depuis un service
test_from_service() {
    local source_service=$1
    local source_namespace=$2
    local pod_selector=$3
    shift 3

    echo "=================================================="
    echo "Testing connectivity from: $source_service ($source_namespace)"
    echo "=================================================="

    # Obtenir le nom du pod
    POD_NAME=$(kubectl get pod -n "$source_namespace" -l "$pod_selector" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$POD_NAME" ]; then
        echo -e "${RED}❌ No pod found for $source_service${NC}"
        return 1
    fi

    echo "Pod: $POD_NAME"
    echo ""

    # Créer le fichier HTML
    OUTPUT_FILE="$OUTPUT_DIR/${source_service}_connectivity_${TIMESTAMP}.html"

    # Services à tester (passés en argument)
    declare -A SERVICES
    while [ $# -gt 0 ]; do
        SERVICES["$1"]="$2"
        shift 2
    done

    # Générer le header HTML
    generate_html "$source_service" "$source_namespace" "$OUTPUT_FILE" SERVICES

    # Tester chaque service
    for service_name in "${!SERVICES[@]}"; do
        url="${SERVICES[$service_name]}"

        # Exécuter le test depuis le pod
        result=$(kubectl exec -n "$source_namespace" "$POD_NAME" -- /bin/sh -c "$(declare -f test_endpoint); test_endpoint '$service_name' '$url'" 2>/dev/null)

        if [ -z "$result" ]; then
            result="ERROR|error|Connection Failed|0|0|0|Could not execute test in pod"
        fi

        # Ajouter le résultat au HTML
        add_test_result "$OUTPUT_FILE" "$service_name" "$url" "$result"

        # Afficher dans le terminal
        IFS='|' read -r status status_class http_code time_total _ _ _ <<< "$result"
        if [ "$status" = "OK" ]; then
            echo -e "${GREEN}✅ $service_name: $http_code (${time_total}s)${NC}"
        elif [ "$status" = "DEGRADED" ]; then
            echo -e "${YELLOW}⚠️  $service_name: $http_code (${time_total}s)${NC}"
        else
            echo -e "${RED}❌ $service_name: $http_code${NC}"
        fi
    done

    # Fermer les divs HTML
    echo "        </div>" >> "$OUTPUT_FILE"

    echo ""
    echo -e "${GREEN}✅ Report generated: $OUTPUT_FILE${NC}"
    echo ""
}

# ============================================
# Configuration des tests
# ============================================

# Test depuis web-user-portal
test_from_service \
    "web-user-portal" \
    "frontend" \
    "app.kubernetes.io/name=web-user-portal" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health" \
    "Redis Support Storage" "http://redis-support-storage.database.svc.cluster.local:6379/"

# Test depuis core-project-service
test_from_service \
    "core-project-service" \
    "backend" \
    "app=core-project-service" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health" \
    "PostgreSQL Core Project" "http://postgresql-core-project.database.svc.cluster.local:5432/" \
    "MongoDB Core Project" "http://mongodb-core-project.database.svc.cluster.local:27017/" \
    "Redis Core Project" "http://redis-core-project.database.svc.cluster.local:6379/"

# Test depuis core-user-service
test_from_service \
    "core-user-service" \
    "backend" \
    "app=core-user-service" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health" \
    "PostgreSQL Core User" "http://postgresql-core-user.database.svc.cluster.local:5432/"

# Test depuis ai-analysis-service
test_from_service \
    "ai-analysis-service" \
    "backend" \
    "app=ai-analysis-service" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health"

# Test depuis support-storage-service
test_from_service \
    "support-storage-service" \
    "backend" \
    "app=support-storage-service" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Redis Support Storage" "http://redis-support-storage.database.svc.cluster.local:6379/"

echo "=================================================="
echo "All tests completed!"
echo "Reports location: $OUTPUT_DIR"
echo "=================================================="
echo ""
echo "To view reports, copy them to your local machine:"
echo "scp -r debian@51.178.52.51:$OUTPUT_DIR ./connectivity-reports"