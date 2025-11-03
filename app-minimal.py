import os
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Simple in-memory storage for demo
items = [
    {"id": 1, "name": "Sample Item 1", "description": "Demo item from East US", "created_at": "2025-11-03", "updated_at": "2025-11-03"},
    {"id": 2, "name": "Sample Item 2", "description": "Demo item from Central US", "created_at": "2025-11-03", "updated_at": "2025-11-03"}
]
next_id = 3

@app.route('/')
def index():
    return render_template('index.html', items=[(item['id'], item['name'], item['description'], item['created_at'], item['updated_at']) for item in items])

@app.route('/api/items', methods=['GET'])
def get_items():
    return jsonify(items)

@app.route('/api/items', methods=['POST'])
def create_item():
    global next_id
    data = request.get_json()
    name = data.get('name')
    description = data.get('description', '')
    
    if not name:
        return jsonify({'error': 'Name is required'}), 400
    
    new_item = {
        'id': next_id,
        'name': name,
        'description': description,
        'created_at': '2025-11-03',
        'updated_at': '2025-11-03'
    }
    items.append(new_item)
    next_id += 1
    
    return jsonify(new_item), 201

@app.route('/api/items/<int:item_id>', methods=['GET'])
def get_item(item_id):
    item = next((item for item in items if item['id'] == item_id), None)
    if not item:
        return jsonify({'error': 'Item not found'}), 404
    return jsonify(item)

@app.route('/api/items/<int:item_id>', methods=['PUT'])
def update_item(item_id):
    data = request.get_json()
    name = data.get('name')
    description = data.get('description', '')
    
    if not name:
        return jsonify({'error': 'Name is required'}), 400
    
    item = next((item for item in items if item['id'] == item_id), None)
    if not item:
        return jsonify({'error': 'Item not found'}), 404
    
    item['name'] = name
    item['description'] = description
    item['updated_at'] = '2025-11-03'
    
    return jsonify(item)

@app.route('/api/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    global items
    items = [item for item in items if item['id'] != item_id]
    return jsonify({'message': 'Item deleted successfully'})

@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'database': 'in-memory', 'region': os.environ.get('WEBSITE_SITE_NAME', 'unknown')})

@app.route('/debug')
def debug_info():
    return jsonify({
        'status': 'working',
        'region': os.environ.get('WEBSITE_SITE_NAME', 'unknown'),
        'items_count': len(items),
        'python_version': os.sys.version
    })

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 8000)))