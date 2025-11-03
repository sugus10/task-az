# Azure High Availability CRUD Application

A production-ready, highly available CRUD web application deployed on Azure with multi-region support, load balancing, and secure configuration management.

## 🏗️ Architecture

```
┌─────────────────────┐
│  Traffic Manager    │
│  (Load Balancer)    │
└──────────┬──────────┘
           │
┌──────────────┴──────────────┐
│                             │
┌───────────▼──────────┐    ┌───────────▼──────────┐
│  East US Web App     │    │ Central US Web App   │
│  (Python/Flask)      │    │  (Python/Flask)     │
└───────────┬──────────┘    └───────────┬──────────┘
           │                             │
           └──────────────┬──────────────┘
                         │
           ┌──────────────┴──────────────┐
           │                             │
┌───────────▼──────────┐    ┌───────────▼──────────┐
│   Azure Key Vault    │    │  Azure SQL Database  │
│  (Connection String) │    │    (West US)         │
└──────────────────────┘    └──────────────────────┘
```

## 🚀 Features

### High Availability
- **Multi-region deployment**: East US and Central US
- **Traffic Manager**: Performance-based routing with automatic failover
- **Health monitoring**: Built-in health checks for both regions

### Security
- **Azure Key Vault**: Secure storage of database connection strings
- **Managed Identity**: No passwords or connection strings in code
- **SQL Database**: Encrypted connections and firewall rules

### Application Features
- **Full CRUD Operations**: Create, Read, Update, Delete items
- **Responsive UI**: Bootstrap 5 with mobile-friendly design
- **Real-time Updates**: AJAX-based operations without page refresh
- **Error Handling**: Comprehensive error handling and user feedback

## 🛠️ Technology Stack

- **Backend**: Python 3.11 + Flask
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Database**: Azure SQL Database
- **Security**: Azure Key Vault + Managed Identity
- **Load Balancing**: Azure Traffic Manager
- **Hosting**: Azure App Service (Linux)

## 📦 Quick Deployment

### Prerequisites
- Azure CLI installed and configured
- Active Azure subscription
- Bash shell (Linux/macOS/WSL)

### One-Command Deployment
```bash
./deploy.sh
```

This script will:
1. Create all Azure resources
2. Configure security and networking
3. Deploy the application code
4. Set up Traffic Manager for load balancing

### Manual Deployment Steps

1. **Login to Azure**
   ```bash
   az login
   ```

2. **Run the deployment script**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Wait for completion** (5-10 minutes)

4. **Access your application**
   - Traffic Manager URL: `https://tm-crud-{timestamp}.trafficmanager.net`
   - East US: `https://webapp-crud-east-{timestamp}.azurewebsites.net`
   - Central US: `https://webapp-crud-central-{timestamp}.azurewebsites.net`

## 🧪 Testing the Application

### Basic Functionality
1. **Add Items**: Use the form to create new items
2. **View Items**: See all items in the table
3. **Edit Items**: Click "Edit" to modify existing items
4. **Delete Items**: Click "Delete" to remove items

### High Availability Testing
1. **Load Balancing**: Access via Traffic Manager URL
2. **Failover**: Stop one App Service to test automatic failover
3. **Health Check**: Visit `/health` endpoint on each region

### API Endpoints
- `GET /api/items` - List all items
- `POST /api/items` - Create new item
- `GET /api/items/{id}` - Get specific item
- `PUT /api/items/{id}` - Update item
- `DELETE /api/items/{id}` - Delete item
- `GET /health` - Health check

## 🔧 Configuration

### Environment Variables
- `KEY_VAULT_URL`: Azure Key Vault URL (automatically set)
- `PORT`: Application port (default: 5000)

### Database Schema
```sql
CREATE TABLE Items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
)
```

## 🏃‍♂️ Local Development

1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set environment variables**
   ```bash
   export SQL_CONNECTION_STRING="your-connection-string"
   ```

3. **Run the application**
   ```bash
   python app.py
   ```

4. **Access locally**
   ```
   http://localhost:5000
   ```

## 📊 Monitoring and Logs

### Azure Portal
- **Application Insights**: Monitor performance and errors
- **Log Stream**: Real-time application logs
- **Metrics**: CPU, memory, and request metrics

### Health Monitoring
- Health endpoint: `/health`
- Returns database connectivity status
- Used by Traffic Manager for health probes

## 💰 Cost Optimization

### Current Resources
- 2x App Service Plans (S1): ~$146/month
- 1x SQL Database (S0): ~$15/month
- 1x Key Vault: ~$0.03/month
- 1x Traffic Manager: ~$0.54/month

### Cost Reduction Tips
1. Use B1 App Service Plans for development
2. Scale down SQL Database to Basic tier
3. Delete resources when not needed:
   ```bash
   az group delete --name rg-crud-app-{timestamp} --yes
   ```

## 🔒 Security Best Practices

### Implemented
- ✅ Managed Identity for Key Vault access
- ✅ SQL Database firewall rules
- ✅ HTTPS enforcement
- ✅ Connection string encryption
- ✅ Input validation and sanitization

### Additional Recommendations
- Enable Application Insights for monitoring
- Set up Azure Security Center
- Configure backup policies
- Implement rate limiting

## 🚨 Troubleshooting

### Common Issues

1. **Application not starting**
   - Check logs in Azure Portal
   - Verify Python runtime version
   - Ensure all dependencies are installed

2. **Database connection errors**
   - Verify Key Vault permissions
   - Check SQL Server firewall rules
   - Confirm managed identity is enabled

3. **Traffic Manager not routing**
   - Wait for DNS propagation (5 minutes)
   - Check endpoint health status
   - Verify web app is running

### Debug Commands
```bash
# Check resource group
az group show --name rg-crud-app-{timestamp}

# View web app logs
az webapp log tail --name webapp-crud-east-{timestamp} --resource-group rg-crud-app-{timestamp}

# Test endpoints
curl https://webapp-crud-east-{timestamp}.azurewebsites.net/health
```

## 📚 Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure Traffic Manager](https://docs.microsoft.com/en-us/azure/traffic-manager/)
- [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for Azure Cloud**