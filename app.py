import os
import pyodbc
from flask import Flask, render_template, request, jsonify, redirect, url_for
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from datetime import datetime

app = Flask(__name__)

# Azure Key Vault configuration
def get_connection_string():
    # First try environment variable (simpler approach)
    connection_string = os.environ.get('SQL_CONNECTION_STRING')
    if connection_string:
        return connection_string
    
    # Fallback to Key Vault if configured
    try:
        vault_url = os.environ.get('KEY_VAULT_URL')
        if vault_url:
            credential = DefaultAzureCredential()
            client = SecretClient(vault_url=vault_url, credential=credential)
            connection_string = client.get_secret("sql-connection-string").value
            return connection_string
    except Exception as e:
        print(f"Error accessing Key Vault: {e}")
    
    # Final fallback
    return os.environ.get('DATABASE_URL', '')

def get_db_connection():
    connection_string = get_connection_string()
    if not connection_string:
        raise Exception("No database connection string found")
    
    return pyodbc.connect(connection_string)

def init_database():
    """Initialize database table if it doesn't exist"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Create Items table if it doesn't exist
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
        
        conn.commit()
        cursor.close()
        conn.close()
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database initialization error: {e}")

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, created_at, updated_at FROM Items ORDER BY created_at DESC")
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return render_template('index.html', items=items)
    except Exception as e:
        return render_template('index.html', items=[], error=str(e))

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
        cursor.execute(
            "INSERT INTO Items (name, description) VALUES (?, ?)",
            (name, description)
        )
        conn.commit()
        
        # Get the created item
        cursor.execute("SELECT TOP 1 id, name, description, created_at, updated_at FROM Items ORDER BY id DESC")
        item = cursor.fetchone()
        cursor.close()
        conn.close()
        
        return jsonify({
            'id': item[0],
            'name': item[1],
            'description': item[2],
            'created_at': item[3].isoformat() if item[3] else None,
            'updated_at': item[4].isoformat() if item[4] else None
        }), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/items/<int:item_id>', methods=['GET'])
def get_item(item_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, description, created_at, updated_at FROM Items WHERE id = ?", (item_id,))
        item = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if not item:
            return jsonify({'error': 'Item not found'}), 404
        
        return jsonify({
            'id': item[0],
            'name': item[1],
            'description': item[2],
            'created_at': item[3].isoformat() if item[3] else None,
            'updated_at': item[4].isoformat() if item[4] else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/items/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    try:
        data = request.get_json()
        name = data.get('name')
        description = data.get('description', '')
        
        if not name:
            return jsonify({'error': 'Name is required'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Items SET name = ?, description = ?, updated_at = GETDATE() WHERE id = ?",
            (name, description, item_id)
        )
        
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Item not found'}), 404
        
        conn.commit()
        
        # Get the updated item
        cursor.execute("SELECT id, name, description, created_at, updated_at FROM Items WHERE id = ?", (item_id,))
        item = cursor.fetchone()
        cursor.close()
        conn.close()
        
        return jsonify({
            'id': item[0],
            'name': item[1],
            'description': item[2],
            'created_at': item[3].isoformat() if item[3] else None,
            'updated_at': item[4].isoformat() if item[4] else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Items WHERE id = ?", (item_id,))
        
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Item not found'}), 404
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'message': 'Item deleted successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

if __name__ == '__main__':
    init_database()
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))