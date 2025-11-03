#!/bin/bash

# Add database integration to the working app

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
SQL_SERVER="sqlserver${TIMESTAMP}"
SQL_DATABASE="myDatabase"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd123!"

echo "🔧 Adding Database Integration to Working App"
echo "============================================="

# Create app with database integration
cat > app.py << 'EOF'
import os
import pyodbc
from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)

# Database connection
def get_db_connection():
    # Try different connection string sources
    connection_string = os.environ.get('SQLAZURECONNSTR_DefaultConnection')
    if not connection_string:
        connection_string = os.environ.get('SQL_CONNECTION_STRING')
    if not connection_string:
        # Fallback connection string
        server = os.environ.get('SQL_SERVER', 'sqlserver20251103145006.database.windows.net')
        database = os.environ.get('SQL_DATABASE', 'myDatabase')
        username = os.environ.get('SQL_ADMIN', 'sqladmin')
        password = os.environ.get('SQL_PASSWORD', 'P@ssw0rd123!')
        connection_string = f"Driver={{ODBC Driver 18 for SQL Server}};Server=tcp:{server},1433;Database={database};Uid={username};Pwd={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    
    return pyodbc.connect(connection_string)

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
                         ('Sample Item 1', 'Database integration working!'))
            cursor.execute("INSERT INTO Items (name, description) VALUES (?, ?)", 
                         ('Sample Item 2', 'Azure SQL Database connected'))
        
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Database error: {e}")
        return False

HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Azure CRUD App - Database Integrated!</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h1>🎉 Azure CRUD Application - Database Integrated!</h1>
    <h2>Multi-Region High Availability Deployment</h2>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5>Status</h5></div>
                <div class="card-body">
                    <p><strong>Status:</strong> <span class="badge bg-success">✅ WORKING</span></p>
                    <p><strong>Region:</strong> Central US</p>
                    <p><strong>Database:</strong> <span class="badge bg-primary">Azure SQL Database</span></p>
                    <p><strong>Items Count:</strong> {{ items|length }}</p>
                </div>
            </div>
        </div>
        
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
                        <button type="submit" class="btn btn-primary">Add Item</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header"><h5>Items from Database</h5></div>
        <div class="card-body">
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
        </div>
    </div>
    
    <div class="card mt-4">
        <div class="card-header"><h5>API Endpoints</h5></div>
        <div class="card-body">
            <ul>
                <li><a href="/api/items">/api/items</a> - GET all items</li>
                <li><a href="/health">/health</a> - Health check</li>
                <li><a href="/debug">/debug</a> - Debug info</li>
            </ul>
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
    if (confirm('Delete this item?')) {
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
        return f"Database error: {e}"

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
        return jsonify({"status": "healthy", "database": "connected", "items_count": count})
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 500

@app.route('/debug')
def debug():
    env_vars = {}
    for key in os.environ:
        if 'SQL' in key.upper() or 'DATABASE' in key.upper():
            env_vars[key] = "***" if 'PASSWORD' in key.upper() else os.environ[key][:50]
    
    return jsonify({
        "environment_variables": env_vars,
        "database_test": "checking..."
    })

if __name__ == '__main__':
    init_database()
    app.run(host='0.0.0.0', port=8000)
EOF

# Update requirements to include database driver
cat > requirements.txt << 'EOF'
Flask==2.3.3
pyodbc==4.0.39
EOF

# Set the database connection environment variables
echo "Setting database connection..."
az webapp config appsettings set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --settings SQL_SERVER="${SQL_SERVER}.database.windows.net" \
              SQL_DATABASE="$SQL_DATABASE" \
              SQL_ADMIN="$SQL_ADMIN" \
              SQL_PASSWORD="$SQL_PASSWORD"

# Deploy the updated app
echo "Deploying app with database integration..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "centralus"

echo ""
echo "✅ Database integration added!"
echo ""
echo "🧪 Test your database-integrated app:"
echo "Main app: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Health: https://${WEB_APP_CENTRAL}.azurewebsites.net/health"
echo "API: https://${WEB_APP_CENTRAL}.azurewebsites.net/api/items"
echo ""
echo "📋 Features:"
echo "✅ Azure SQL Database integration"
echo "✅ Full CRUD operations"
echo "✅ Bootstrap UI"
echo "✅ Real-time add/delete"
echo "✅ Multi-region ready"