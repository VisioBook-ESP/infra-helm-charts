#!/bin/bash

# Configuration
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="/tmp/connectivity-reports"
OUTPUT_FILE="$OUTPUT_DIR/full-connectivity-report_${TIMESTAMP}.html"
mkdir -p "$OUTPUT_DIR"

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=================================================="
echo "🔌 Unified Connectivity Report Generator"
echo "=================================================="
echo ""

# Fonction pour tester un endpoint
test_endpoint() {
    local service_name=$1
    local url=$2
    local timeout=${3:-5}

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

    # Retourner les résultats
    echo "$status|$status_class|$http_code|$time_total|$time_dns|$time_connect|$response_body"
}

# Générer le header HTML
cat > "$OUTPUT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Full Connectivity Report - Kubernetes Cluster</title>
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
            max-width: 1600px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 50px;
            text-align: center;
        }

        .header h1 {
            font-size: 3em;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }

        .header .subtitle {
            font-size: 1.3em;
            opacity: 0.95;
            margin-bottom: 10px;
        }

        .header .timestamp {
            margin-top: 15px;
            font-size: 1em;
            opacity: 0.85;
            font-family: 'Courier New', monospace;
        }

        .global-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            padding: 40px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-bottom: 3px solid #667eea;
        }

        .summary-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: all 0.3s;
            border: 2px solid transparent;
        }

        .summary-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .summary-card .icon {
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .summary-card .number {
            font-size: 3em;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .summary-card .label {
            color: #666;
            font-size: 0.95em;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }

        .summary-card.total { border-color: #667eea; }
        .summary-card.total .number { color: #667eea; }

        .summary-card.success { border-color: #28a745; }
        .summary-card.success .number { color: #28a745; }

        .summary-card.warning { border-color: #ffc107; }
        .summary-card.warning .number { color: #ffc107; }

        .summary-card.error { border-color: #dc3545; }
        .summary-card.error .number { color: #dc3545; }

        .nav-tabs {
            display: flex;
            background: #f8f9fa;
            padding: 0 40px;
            border-bottom: 2px solid #e0e0e0;
            overflow-x: auto;
        }

        .nav-tab {
            padding: 20px 30px;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
            font-weight: 600;
            color: #666;
            white-space: nowrap;
        }

        .nav-tab:hover {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
        }

        .nav-tab.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: white;
        }

        .content {
            padding: 40px;
        }

        .source-section {
            display: none;
        }

        .source-section.active {
            display: block;
            animation: fadeIn 0.5s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .source-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .source-header h2 {
            font-size: 2em;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .source-stats {
            display: flex;
            gap: 20px;
            font-size: 0.95em;
        }

        .source-stat {
            background: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
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
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transform: translateY(-3px);
        }

        .service-test.success {
            border-left: 6px solid #28a745;
            background: linear-gradient(to right, rgba(40, 167, 69, 0.05) 0%, white 10%);
        }
        .service-test.warning {
            border-left: 6px solid #ffc107;
            background: linear-gradient(to right, rgba(255, 193, 7, 0.05) 0%, white 10%);
        }
        .service-test.error {
            border-left: 6px solid #dc3545;
            background: linear-gradient(to right, rgba(220, 53, 69, 0.05) 0%, white 10%);
        }

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
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-badge {
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: bold;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .status-badge.success {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            color: #155724;
        }

        .status-badge.warning {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
            color: #856404;
        }

        .status-badge.error {
            background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
            color: #721c24;
        }

        .service-url {
            color: #667eea;
            font-family: 'Courier New', monospace;
            background: #f8f9fa;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            word-break: break-all;
            border-left: 4px solid #667eea;
            font-size: 0.95em;
        }

        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .metric {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 18px;
            border-radius: 10px;
            text-align: center;
            border: 1px solid #dee2e6;
            transition: all 0.3s;
        }

        .metric:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .metric-label {
            color: #666;
            font-size: 0.85em;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }

        .metric-value {
            font-size: 1.4em;
            font-weight: bold;
            color: #333;
        }

        .metric-value.good { color: #28a745; }
        .metric-value.warning { color: #ffc107; }
        .metric-value.bad { color: #dc3545; }

        .response-section {
            margin-top: 20px;
        }

        .response-body {
            background: #282c34;
            color: #abb2bf;
            padding: 20px;
            border-radius: 10px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            max-height: 400px;
            overflow-y: auto;
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.3);
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
            gap: 10px;
            color: #667eea;
            font-weight: bold;
            margin-bottom: 12px;
            padding: 8px 16px;
            background: rgba(102, 126, 234, 0.1);
            border-radius: 8px;
            transition: all 0.3s;
        }

        .collapsible:hover {
            background: rgba(102, 126, 234, 0.2);
            color: #764ba2;
        }

        .collapsible::before {
            content: '▼';
            transition: transform 0.3s;
            font-size: 0.8em;
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
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 30px;
            text-align: center;
            color: #666;
            border-top: 3px solid #667eea;
        }

        .footer p {
            margin: 5px 0;
        }

        .footer .footer-title {
            font-size: 1.2em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }

        @media (max-width: 768px) {
            .header h1 {
                font-size: 2em;
            }

            .nav-tab {
                padding: 15px 20px;
            }

            .service-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .metrics {
                grid-template-columns: 1fr;
            }

            .global-summary {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Scrollbar styling */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }

        ::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb {
            background: #667eea;
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #764ba2;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌐 Full Cluster Connectivity Report</h1>
            <div class="subtitle">Kubernetes Service Mesh</div>
            <div class="timestamp">Generated: TIMESTAMP_PLACEHOLDER</div>
        </div>

        <div class="global-summary">
            <div class="summary-card total">
                <div class="icon">🎯</div>
                <div class="number" id="total-count">0</div>
                <div class="label">Total Tests</div>
            </div>
            <div class="summary-card success">
                <div class="icon">✅</div>
                <div class="number" id="success-count">0</div>
                <div class="label">Successful</div>
            </div>
            <div class="summary-card warning">
                <div class="icon">⚠️</div>
                <div class="number" id="warning-count">0</div>
                <div class="label">Degraded</div>
            </div>
            <div class="summary-card error">
                <div class="icon">❌</div>
                <div class="number" id="error-count">0</div>
                <div class="label">Failed</div>
            </div>
        </div>

        <div class="nav-tabs" id="nav-tabs">
            <!-- Tabs will be inserted here -->
        </div>

        <div class="content" id="content">
            <!-- Content will be inserted here -->
        </div>

        <div class="footer">
            <p class="footer-title">🚀 Visiobook Connectivity Test Suite</p>
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

        // Tab navigation
        function showTab(sourceId) {
            // Hide all sections
            document.querySelectorAll('.source-section').forEach(section => {
                section.classList.remove('active');
            });

            // Remove active class from all tabs
            document.querySelectorAll('.nav-tab').forEach(tab => {
                tab.classList.remove('active');
            });

            // Show selected section
            document.getElementById(sourceId).classList.add('active');

            // Add active class to clicked tab
            event.target.classList.add('active');
        }

        // Update global summary counts
        function updateGlobalSummary() {
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
        window.addEventListener('load', function() {
            updateGlobalSummary();

            // Activate first tab
            const firstTab = document.querySelector('.nav-tab');
            if (firstTab) {
                firstTab.click();
            }
        });
    </script>
</body>
</html>
EOF

# Remplacer le placeholder de timestamp
sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/g" "$OUTPUT_FILE"

# Fonction pour ajouter un onglet
add_tab() {
    local source_id=$1
    local source_name=$2
    local is_first=$3

    local active_class=""
    if [ "$is_first" = "true" ]; then
        active_class="active"
    fi

    # Ajouter l'onglet
    sed -i "/<div class=\"nav-tabs\" id=\"nav-tabs\">/a\\
            <div class=\"nav-tab $active_class\" onclick=\"showTab('$source_id')\">$source_name</div>" "$OUTPUT_FILE"
}

# Fonction pour commencer une section source
start_source_section() {
    local source_id=$1
    local source_name=$2
    local source_namespace=$3
    local is_first=$4

    local active_class=""
    if [ "$is_first" = "true" ]; then
        active_class="active"
    fi

    cat >> "$OUTPUT_FILE" << EOF
            <div class="source-section $active_class" id="$source_id">
                <div class="source-header">
                    <h2>🎯 $source_name</h2>
                    <div class="source-stats">
                        <div class="source-stat">📦 Namespace: <strong>$source_namespace</strong></div>
                        <div class="source-stat" id="$source_id-success">✅ <span>0</span> OK</div>
                        <div class="source-stat" id="$source_id-warning">⚠️ <span>0</span> Degraded</div>
                        <div class="source-stat" id="$source_id-error">❌ <span>0</span> Failed</div>
                    </div>
                </div>
EOF
}

# Fonction pour fermer une section source
end_source_section() {
    echo "            </div>" >> "$OUTPUT_FILE"
}

# Fonction pour ajouter un test
add_test_result() {
    local service_name=$1
    local url=$2
    local result=$3

    IFS='|' read -r status status_class http_code time_total time_dns time_connect response_body <<< "$result"

    # Formatter le temps en millisecondes
    time_total_ms=$(printf "%.0f" $(echo "$time_total * 1000" | bc 2>/dev/null || echo "0"))
    time_dns_ms=$(printf "%.0f" $(echo "$time_dns * 1000" | bc 2>/dev/null || echo "0"))
    time_connect_ms=$(printf "%.0f" $(echo "$time_connect * 1000" | bc 2>/dev/null || echo "0"))

    # Déterminer les classes de couleur pour les métriques
    time_class="good"
    if [ "$time_total_ms" -gt 1000 ]; then
        time_class="warning"
    fi
    if [ "$time_total_ms" -gt 3000 ]; then
        time_class="bad"
    fi

    # Formater le JSON si possible
    formatted_body=$(echo "$response_body" | python3 -m json.tool 2>/dev/null || echo "$response_body")

    # Échapper les caractères spéciaux pour HTML
    formatted_body=$(echo "$formatted_body" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    # Créer le HTML pour ce test
    cat >> "$OUTPUT_FILE" << EOF
                <div class="service-test $status_class">
                    <div class="service-header">
                        <div class="service-name">
                            <span>🎯</span>
                            <span>$service_name</span>
                        </div>
                        <div class="status-badge $status_class">$status</div>
                    </div>

                    <div class="service-url">🔗 $url</div>

                    <div class="metrics">
                        <div class="metric">
                            <div class="metric-label">HTTP Status</div>
                            <div class="metric-value">$http_code</div>
                        </div>
                        <div class="metric">
                            <div class="metric-label">Total Time</div>
                            <div class="metric-value $time_class">${time_total_ms} ms</div>
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

                    <div class="response-section">
                        <div class="collapsible">📄 Response Body (click to expand)</div>
                        <div class="collapsible-content collapsed">
                            <div class="response-body">
                                <pre>$formatted_body</pre>
                            </div>
                        </div>
                    </div>
                </div>
EOF
}

# Fonction pour tester depuis un service
test_from_service() {
    local source_service=$1
    local source_namespace=$2
    local pod_selector=$3
    local source_id=$4
    local is_first=$5
    shift 5

    echo -e "${BLUE}=================================================="
    echo "Testing from: $source_service ($source_namespace)"
    echo -e "==================================================${NC}"

    # Obtenir le nom du pod
    POD_NAME=$(kubectl get pod -n "$source_namespace" -l "$pod_selector" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$POD_NAME" ]; then
        echo -e "${RED}❌ No pod found for $source_service${NC}"
        echo ""
        return 1
    fi

    echo "Pod: $POD_NAME"
    echo ""

    # Ajouter l'onglet
    add_tab "$source_id" "$source_service" "$is_first"

    # Commencer la section
    start_source_section "$source_id" "$source_service" "$source_namespace" "$is_first"

    # Services à tester (passés en argument)
    declare -A SERVICES
    while [ $# -gt 0 ]; do
        SERVICES["$1"]="$2"
        shift 2
    done

    # Tester chaque service
    for service_name in "${!SERVICES[@]}"; do
        url="${SERVICES[$service_name]}"

        echo -n "  Testing $service_name... "

        # Exécuter le test depuis le pod
        result=$(kubectl exec -n "$source_namespace" "$POD_NAME" -- /bin/sh -c "$(declare -f test_endpoint); test_endpoint '$service_name' '$url'" 2>/dev/null)

        if [ -z "$result" ]; then
            result="ERROR|error|Connection Failed|0|0|0|Could not execute test in pod"
        fi

        # Ajouter le résultat au HTML
        add_test_result "$service_name" "$url" "$result"

        # Afficher dans le terminal
        IFS='|' read -r status status_class http_code time_total _ _ _ <<< "$result"
        if [ "$status" = "OK" ]; then
            echo -e "${GREEN}✅ $http_code (${time_total}s)${NC}"
        elif [ "$status" = "DEGRADED" ]; then
            echo -e "${YELLOW}⚠️  $http_code (${time_total}s)${NC}"
        else
            echo -e "${RED}❌ $http_code${NC}"
        fi
    done

    # Fermer la section
    end_source_section

    echo ""
}

# ============================================
# CONFIGURATION DES TESTS
# ============================================

IS_FIRST="true"

# Test depuis web-user-portal
test_from_service \
    "web-user-portal" \
    "frontend" \
    "app.kubernetes.io/name=web-user-portal" \
    "web-user-portal-section" \
    "$IS_FIRST" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health"

IS_FIRST="false"

# Test depuis core-project-service
test_from_service \
    "core-project-service" \
    "backend" \
    "app=core-project-service" \
    "core-project-section" \
    "$IS_FIRST" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health" \
    "Redis Core Project" "http://redis-core-project.database.svc.cluster.local:6379/"

# Test depuis core-user-service
test_from_service \
    "core-user-service" \
    "backend" \
    "app=core-user-service" \
    "core-user-section" \
    "$IS_FIRST" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health" \
    "Core Database Service" "http://core-database-service.database.svc.cluster.local:3000/api/v1/health"

# Test depuis ai-analysis-service
test_from_service \
    "ai-analysis-service" \
    "backend" \
    "app=ai-analysis-service" \
    "ai-analysis-section" \
    "$IS_FIRST" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "Support Storage Service" "http://support-storage-service.backend.svc.cluster.local:80/health"

# Test depuis support-storage-service
test_from_service \
    "support-storage-service" \
    "backend" \
    "app=support-storage-service" \
    "support-storage-section" \
    "$IS_FIRST" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "AI Analysis Service" "http://ai-analysis-service.backend.svc.cluster.local:80/health" \
    "Redis Support Storage" "http://redis-support-storage.database.svc.cluster.local:6379/"

# Test depuis core-database-service
test_from_service \
    "core-database-service" \
    "database" \
    "app=core-database-service" \
    "core-database-section" \
    "$IS_FIRST" \
    "Core Project Service" "http://core-project-service.backend.svc.cluster.local:3000/health" \
    "Core User Service" "http://core-user-service.backend.svc.cluster.local:80/health" \
    "PostgreSQL Core Database" "http://postgresql-core-database.database.svc.cluster.local:5432/" \
    "Redis Core Database" "http://redis-core-database.database.svc.cluster.local:6379/"

echo "=================================================="
echo -e "${GREEN}✅ Full report generated!${NC}"
echo "=================================================="
echo ""
echo "Report location: $OUTPUT_FILE"
echo ""
echo "To view on your local machine:"
echo "  scp debian@51.178.52.51:$OUTPUT_FILE ./"
echo "  xdg-open $(basename $OUTPUT_FILE)"
echo ""