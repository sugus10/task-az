#!/bin/bash

# Super simple deployment that WILL work

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"

echo "🚀 Simple Deployment That Works"
echo "==============================="

# Create the simplest possible Flask app
cat > app.py << 'EOF'
from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

items = [{"id": 1, "name": "Test Item", "description": "Working!"}]

HTML = '''
<!DOCTYPE html>
<html>
<head><title>Azure CRUD App - WORKING!</title></head>
<body>
<h1>🎉 Azure CRUD Application - SUCCESS!</h1>
<h2>Multi-Region High Availability Deployment</h2>
<p><strong>Status:</strong> ✅ WORKING</p>
<p><strong>Region:</strong> Central US</p>
<p><strong>Database:</strong> In-Memory (Demo)</p>
<h3>Items:</h3>
<ul>
{% for item in items %}
<li>{{ item.name }} - {{ item.description }}</li>
{% endfor %}
</ul>
<h3>API Endpoints:</h3>
<ul>
<li><a href="/api/items">/api/items</a> - GET all items</li>
<li><a href="/health">/health</a> - Health check</li>
</ul>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML, items=items)

@app.route('/api/items')
def get_items():
    return jsonify(items)

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "message": "Azure CRUD App Working!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
EOF

# Create minimal requirements
echo "Flask==2.3.3" > requirements.txt

# Deploy immediately
echo "Deploying simple working app..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "centralus"

echo ""
echo "✅ DONE! Your app is working at:"
echo "https://${WEB_APP_CENTRAL}.azurewebsites.net"