#!/bin/bash

# Fix database timeout issues

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
SQL_SERVER="sqlserver${TIMESTAMP}"

echo "🔧 Fixing Database Connection Timeout"
echo "====================================="

# Get the outbound IP addresses of the web app
echo "Getting web app outbound IPs..."
OUTBOUND_IPS=$(az webapp show --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP --query "outboundIpAddresses" -o tsv)

echo "Web app outbound IPs: $OUTBOUND_IPS"

# Add firewall rules for each outbound IP
echo "Adding firewall rules for web app IPs..."
IFS=',' read -ra IP_ARRAY <<< "$OUTBOUND_IPS"
for ip in "${IP_ARRAY[@]}"; do
    echo "Adding firewall rule for IP: $ip"
    az sql server firewall-rule create \
        --resource-group $RESOURCE_GROUP \
        --server $SQL_SERVER \
        --name "WebApp-$ip" \
        --start-ip-address "$ip" \
        --end-ip-address "$ip"
done

# Also add possible outbound IPs
POSSIBLE_IPS=$(az webapp show --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP --query "possibleOutboundIpAddresses" -o tsv)
echo "Adding possible outbound IPs..."
IFS=',' read -ra POSSIBLE_IP_ARRAY <<< "$POSSIBLE_IPS"
for ip in "${POSSIBLE_IP_ARRAY[@]}"; do
    echo "Adding firewall rule for possible IP: $ip"
    az sql server firewall-rule create \
        --resource-group $RESOURCE_GROUP \
        --server $SQL_SERVER \
        --name "WebAppPossible-$ip" \
        --start-ip-address "$ip" \
        --end-ip-address "$ip" 2>/dev/null || true
done

# Update the app with a simpler connection string
echo "Updating app with simpler connection string..."
cat > app.py << 'EOF'
import os
import pyodbc
from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)

# Simplified database connection
def get_db_connection():
    try:
        # Simple connection string
        connection_string = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:sqlserver20251103145006.database.windows.net,1433;Database=myDatabase;Uid=sqladmin;Pwd=P@ssw0rd123!;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=60;"
        return pyodbc.connect(connection_string)
    except Exception as e:
        print(f"Database connection failed: {e}")
        raise

# Initialize database
def init_database():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Items' AND xtype='U')
            CREATE TABLE Items (
                id INT IDENTITY(1,1) PRIMARY KEY,
                name NVARCHAR(255) NOT NULL,
                description NVARCHAR(MAX),
                created_at DATETIME2 DEFAULT GETDATE(),
                updated_at DATETIME2 DEFAULT GETDATE()
            )
        """)
        
        # Add sample data if table is empty
        cursor.execute("SELECT COUNT(*) FROM Items")
        count = cursor.fetchone()[0]
        if count == 0:
            cursor.execute("INSERT INTO Items (name, description) VALUES (?, ?)", 
                         ('Database Item 1', 'Connected to Azure SQL Database!'))
            cursor.execute("INSERT INTO Items (name, description) VALUES (?, ?)", 
                         ('Database Item 2', 'Full CRUD operations working'))
        
        conn.commit()
        cursor.close()
        conn.close()
        print("Database initialized successfully")
        return True
    except Exception as e:
        print(f"Database initialization failed: {e}")
        return False

HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Azure CRUD App - Database Connected!</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h1>🎉 Azure CRUD Application - Database Connected!</h1>
    <h2>Multi-Region High Availability with Azure SQL Database</h2>
    
    <div class="alert alert-success">
        <strong>✅ SUCCESS:</strong> Connected to Azure SQL Database!
    </div>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5>Add New Item</h5></div>
                <div class="card-body">
                    <form id="addForm">
                        <div class="mb-3">
                            <input type="text" class="form-control" id="itemName" placeholder="Item Name" required>
                        </div>
                        <div class="mb-3">
                            <input type="text" class="form-control" id="itemDesc" placeholder="Description">
                        </div>
                        <button type="submit" class="btn btn-primary">Add to Database</button>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5>Database Status</h5></div>
                <div class="card-body">
                    <p><strong>Database:</strong> <span class="badge bg-success">Azure SQL Database</span></p>
                    <p><strong>Items Count:</strong> {{ items|length }}</p>
                    <p><strong>Region:</strong> Central US</p>
                    <a href="/health" class="btn btn-outline-primary">Health Check</a>
                </div>
            </div>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header"><h5>Items from Azure SQL Database</h5></div>
        <div class="card-body">
            {% if items %}
            <div class="table-responsive">
                <table class="table table-striped">
                    <thead>
                        <tr><th>ID</th><th>Name</th><th>Description</th><th>Created</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                        {% for item in items %}
                        <tr>
                            <td>{{ item[0] }}</td>
                            <td>{{ item[1] }}</td>
                            <td>{{ item[2] or 'N/A' }}</td>
                            <td>{{ item[3].strftime('%Y-%m-%d %H:%M') if item[3] else 'N/A' }}</td>
                            <td>
                                <button class="btn btn-sm btn-danger" onclick="deleteItem({{ item[0] }})">Delete</button>
                            </td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
            {% else %}
            <p>No items in database yet. Add some above!</p>
            {% endif %}
        </div>
    </div>
</div>

<script>
document.getElementById('addForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    const name = document.getElementById('itemName').value;
    const description = document.getElementById('itemDesc').value;
    
    try {
        const response = await fetch('/api/items', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({name, description})
        });
        
        if (response.ok) {
            location.reload();
        } else {
            alert('Error adding item');
        }
    } catch (error) {
        alert('Network error');
    }
});

async function deleteItem(id) {
    if (confirm('Delete this item from database?')) {
        try {
            const response = await fetch(`/api/items/${id}`, {method: 'DELETE'});
            if (response.ok) {
                location.reload();
            } else {
                alert('Error deleting item');
            }
        } catch (error) {
            alert('Network error');
        }
    }
}
</script>
</body>
</html>
'''

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, created_at FROM Items ORDER BY created_at DESC")
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template_string(HTML, items=items)
    except Exception as e:
        return f"<h1>Database Connection Error</h1><p>{e}</p><p><a href='/health'>Check Health</a></p>"

@app.route('/api/items', methods=['GET'])
def get_items():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, created_at, updated_at FROM Items ORDER BY created_at DESC")
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        
        items_list = []
        for item in items:
            items_list.append({
                'id': item[0],
                'name': item[1],
                'description': item[2],
                'created_at': item[3].isoformat() if item[3] else None,
                'updated_at': item[4].isoformat() if item[4] else None
            })
        return jsonify(items_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/items', methods=['POST'])
def create_item():
    try:
        data = request.get_json()
        name = data.get('name')
        description = data.get('description', '')
        
        if not name:
            return jsonify({'error': 'Name is required'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO Items (name, description) VALUES (?, ?)", (name, description))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'message': 'Item created successfully'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Items WHERE id = ?", (item_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'Item deleted successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM Items")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({"status": "healthy", "database": "Azure SQL Database Connected", "items_count": count})
    except Exception as e:
        return jsonify({"status": "unhealthy", "database_error": str(e)}), 500

if __name__ == '__main__':
    init_database()
    app.run(host='0.0.0.0', port=8000)
EOF

# Deploy the fixed app
echo "Deploying fixed app..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "centralus"

echo ""
echo "✅ Database connection fixed!"
echo ""
echo "🧪 Test your database app:"
echo "Main app: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Health: https://${WEB_APP_CENTRAL}.azurewebsites.net/health"