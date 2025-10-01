# E-commerce Application

A modern, full-stack e-commerce application built with React, Node.js, Express, TypeScript, and Azure SQL Database. This application provides a complete shopping experience with user authentication, product management, shopping cart, and order processing.

## 🏗️ Architecture

This is a three-tier application consisting of:

1. **Frontend**: React.js with TypeScript, Tailwind CSS, and modern UI components
2. **Backend**: Node.js with Express.js, TypeScript, and RESTful APIs
3. **Database**: Azure SQL Database with comprehensive schema

## ✨ Features

### User Features
- 🔐 User registration and authentication
- 👤 User profile management
- 🛍️ Product browsing with search and filtering
- 🛒 Shopping cart functionality
- 📦 Order management and tracking
- 📱 Responsive design for all devices

### Admin Features
- 📊 Product management (CRUD operations)
- 👥 User management
- 📈 Order management and status updates
- 🏷️ Category management

### Technical Features
- 🔒 JWT-based authentication
- 🛡️ Input validation and sanitization
- 🚀 API rate limiting
- 📊 Comprehensive error handling
- 🐳 Docker containerization
- 🔄 Real-time cart updates
- 📱 Progressive Web App ready

## 🚀 Azure Infrastructure Deployment

This project includes complete Infrastructure as Code (IaC) using Terraform and automated CI/CD with GitHub Actions.

### Infrastructure Components
- **Azure Container Apps** - Serverless containerized applications
- **Azure SQL Database** - Managed database with private endpoint
- **Azure Container Registry** - Docker image storage
- **Virtual Network** - Network isolation and security
- **Log Analytics** - Centralized logging and monitoring

### Automated Deployment

1. **Setup GitHub Secrets** (see `GITHUB_SECRETS.md`):
   - Azure Service Principal credentials
   - Database passwords
   - JWT secrets

2. **Deploy via GitHub Actions**:
   - Go to **Actions** tab → **"🚀 Deploy Three-Tier Application"**
   - Click **"Run workflow"** → Choose **"deploy"**
   - Wait for automatic infrastructure and application deployment

3. **Access Your Application**:
   - Frontend URL will be provided in the workflow summary
   - Test the complete three-tier application on Azure

### Manual Infrastructure Setup

### Prerequisites

- Node.js 18+ and npm
- Azure SQL Database instance
- Docker and Docker Compose (optional)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd workspace-lb
```

### 2. Backend Setup

```bash
cd ecommerce-app-backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Configure your Azure SQL Database connection in .env
# DB_SERVER=your-server.database.windows.net
# DB_NAME=your-database-name
# DB_USER=your-username
# DB_PASSWORD=your-password

# Initialize the database
# Run the SQL script in src/scripts/init-database.sql on your Azure SQL Database

# Start development server
npm run dev
```

### 3. Frontend Setup

```bash
cd ecommerce-app-frontend

# Install dependencies
npm install

# Start development server
npm start
```

### 4. Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- API Health Check: http://localhost:3001/health

## 🐳 Docker Deployment

### Using Docker Compose

1. Create a `.env` file in the root directory:

```env
# Database Configuration
DB_SERVER=your-server.database.windows.net
DB_NAME=your-database-name
DB_USER=your-username
DB_PASSWORD=your-password

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
```

2. Build and start the services:

```bash
docker-compose up --build
```

3. Access the application:
- Frontend: http://localhost:3000
- Backend: http://localhost:3001

## 📊 Database Schema

The application uses the following main tables:

### Users
- User authentication and profile information
- Admin role management

### Products
- Product catalog with categories
- Inventory management
- Image URLs and descriptions

### CartItems
- Shopping cart functionality
- User-specific cart items

### Orders
- Order management and tracking
- Payment status and shipping information

### OrderItems
- Individual items within orders
- Product details at time of purchase

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile

### Products
- `GET /api/products` - Get all products (with filtering)
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/categories/list` - Get all categories
- `POST /api/products` - Create product (Admin only)
- `PUT /api/products/:id` - Update product (Admin only)
- `DELETE /api/products/:id` - Delete product (Admin only)

### Cart
- `GET /api/cart` - Get user's cart
- `POST /api/cart/add` - Add item to cart
- `PUT /api/cart/update/:productId` - Update cart item quantity
- `DELETE /api/cart/remove/:productId` - Remove item from cart
- `DELETE /api/cart/clear` - Clear entire cart

### Orders
- `GET /api/orders/my-orders` - Get user's orders
- `GET /api/orders/:id` - Get order by ID
- `POST /api/orders/create` - Create new order
- `POST /api/orders/create-from-cart` - Create order from cart
- `PUT /api/orders/:id/status` - Update order status (Admin only)
- `PUT /api/orders/:id/cancel` - Cancel order

## 🛠️ Development

### Backend Development

```bash
cd ecommerce-app-backend

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Run tests
npm test

# Lint code
npm run lint
```

### Frontend Development

```bash
cd ecommerce-app-frontend

# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test

# Lint code
npm run lint
```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
# Server Configuration
PORT=3001
NODE_ENV=development

# Azure SQL Database Configuration
DB_SERVER=your-server.database.windows.net
DB_NAME=your-database-name
DB_USER=your-username
DB_PASSWORD=your-password
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=false

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

#### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:3001/api
```

## 🧪 Testing

### Backend Testing
```bash
cd ecommerce-app-backend
npm test
```

### Frontend Testing
```bash
cd ecommerce-app-frontend
npm test
```

## 📦 Production Deployment

### Azure Deployment

1. **Backend Deployment**:
   - Deploy to Azure App Service
   - Configure environment variables
   - Set up Azure SQL Database connection

2. **Frontend Deployment**:
   - Build the React app: `npm run build`
   - Deploy to Azure Static Web Apps or Azure App Service

3. **Database Setup**:
   - Create Azure SQL Database instance
   - Run the initialization script
   - Configure firewall rules

### Environment-Specific Configuration

- **Development**: Local development with hot reloading
- **Staging**: Docker containers with staging database
- **Production**: Azure services with production database

## 🔒 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Input validation and sanitization
- CORS configuration
- Rate limiting
- SQL injection prevention
- XSS protection
- CSRF protection

## 📱 Mobile Responsiveness

The application is fully responsive and works seamlessly on:
- Desktop computers
- Tablets
- Mobile phones
- Various screen sizes and orientations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the API endpoints

## 🎯 Future Enhancements

- [ ] Payment gateway integration (Stripe, PayPal)
- [ ] Email notifications
- [ ] Advanced search with Elasticsearch
- [ ] Product reviews and ratings
- [ ] Wishlist functionality
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] Real-time chat support
- [ ] Inventory management system

---

Built with ❤️ using modern web technologies.
