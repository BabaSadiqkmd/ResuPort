# Quick Start Guide - JDBC Implementation

## What Was Implemented

Your Resume to Portfolio Builder now has complete **Java and JDBC connectivity** with MySQL support:

### ✅ Features Implemented

1. **Database Persistence Layer** (JDBC)
   - User account management with OAuth2 support
   - Resume file upload and storage
   - Portfolio generation and tracking

2. **Complete REST API**
   - 15+ REST endpoints for user, resume, and portfolio management
   - Full CRUD operations
   - OAuth2 authentication integrated

3. **Data Models** (3 entities)
   - User (accounts, emails, OAuth info)
   - Resume (uploaded files, metadata, status tracking)
   - Portfolio (generated portfolios, content, status)

4. **Service Layer** (3 services)
   - UserService: User management and OAuth integration
   - ResumeService: Resume upload and tracking
   - PortfolioService: Portfolio generation and management

5. **DAO Layer** (3 DAOs)
   - Raw JDBC implementation with PreparedStatement
   - SQL injection prevention
   - Connection pooling via HikariCP

## Project Structure

```
src/main/java/com/portfoliobuilder/
├── model/          # User, Resume, Portfolio entities
├── dao/            # JDBC data access objects
├── service/        # Business logic
├── controller/     # REST API endpoints
└── config/         # Database configuration

src/main/resources/
├── application.yml # Database & app config
└── schema.sql      # MySQL schema
```

## Installation Steps

### 1. Install MySQL Server

**Windows**:
```bash
# Using chocolatey
choco install mysql

# Or download from: https://dev.mysql.com/downloads/mysql/
```

**macOS**:
```bash
brew install mysql
```

**Linux (Ubuntu)**:
```bash
sudo apt-get install mysql-server
```

### 2. Create Database

Start MySQL and create the database:

```bash
# Connect to MySQL
mysql -u root -p

# Run in MySQL client:
CREATE DATABASE portfolio_builder DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit
```

Or run the schema script:
```bash
mysql -u root -p < src/main/resources/schema.sql
```

### 3. Update Configuration

Edit `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/portfolio_builder
    username: root          # Your MySQL username
    password: root          # Your MySQL password
```

### 4. Build the Project

```bash
cd "d:\Resume_to_Portfolio Builder"
mvn clean compile
```

### 5. Run the Application

```bash
mvn spring-boot:run
```

Application will start at: `http://localhost:8080`

## API Quick Reference

### User Management (`/api/users`)

```bash
# Get current user profile
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/users/profile

# Get user by ID
curl http://localhost:8080/api/users/1

# Create new user
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"john","email":"john@example.com","fullName":"John Doe"}' \
  http://localhost:8080/api/users

# Update user
curl -X PUT \
  -H "Content-Type: application/json" \
  -d '{"username":"john_updated","email":"john@example.com"}' \
  http://localhost:8080/api/users/1

# Delete user
curl -X DELETE http://localhost:8080/api/users/1
```

### Resume Management (`/api`)

```bash
# Upload resume
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -F "resume=@resume.pdf" \
  http://localhost:8080/api/upload

# Get user's resumes
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/resumes

# Get resume details
curl http://localhost:8080/api/resume/1

# Delete resume
curl -X DELETE http://localhost:8080/api/resume/1
```

### Portfolio Management (`/api/portfolios`)

```bash
# Create portfolio
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "resumeId": 1,
    "portfolioTitle": "My Portfolio",
    "portfolioUrl": "https://portfolio.example.com"
  }' \
  http://localhost:8080/api/portfolios

# Get portfolio
curl http://localhost:8080/api/portfolios/1

# Get user's portfolios
curl http://localhost:8080/api/portfolios/user/1

# Get portfolios from resume
curl http://localhost:8080/api/portfolios/resume/1

# Update portfolio
curl -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "portfolioTitle": "Updated Portfolio",
    "status": "PUBLISHED"
  }' \
  http://localhost:8080/api/portfolios/1

# Delete portfolio
curl -X DELETE http://localhost:8080/api/portfolios/1

# Get all portfolios
curl http://localhost:8080/api/portfolios
```

## Database Schema

### users table
```sql
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) UNIQUE,
  email VARCHAR(150) UNIQUE,
  full_name VARCHAR(200),
  password VARCHAR(255),
  oauth_provider VARCHAR(50),
  oauth_id VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### resumes table
```sql
CREATE TABLE resumes (
  resume_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  filename VARCHAR(255),
  original_filename VARCHAR(255),
  file_type VARCHAR(50),
  file_size BIGINT,
  file_content LONGBLOB,
  status VARCHAR(50),
  uploaded_at TIMESTAMP,
  parsed_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### portfolios table
```sql
CREATE TABLE portfolios (
  portfolio_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  resume_id INT,
  portfolio_title VARCHAR(255),
  portfolio_html LONGTEXT,
  portfolio_url VARCHAR(500),
  status VARCHAR(50),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (resume_id) REFERENCES resumes(resume_id)
);
```

## Key Technologies

- **Java 21 LTS**: Latest long-term support Java version
- **Spring Boot 3.2.3**: Modern web framework
- **JDBC**: Low-level database access with full control
- **MySQL 8.0+**: Reliable relational database
- **HikariCP**: High-performance connection pooling
- **Maven 3.9.15**: Build and dependency management

## JDBC Features Used

✅ **PreparedStatement** - SQL injection prevention  
✅ **Connection Pooling** - HikariCP for performance  
✅ **RowMapper** - ResultSet to Java object mapping  
✅ **Auto-generated Keys** - Retrieve inserted IDs  
✅ **JdbcTemplate** - Spring's JDBC helper  

## Testing the Implementation

### Verify Compilation
```bash
cd "d:\Resume_to_Portfolio Builder"
mvn clean compile
```
Expected: ✅ BUILD SUCCESS

### Run Application
```bash
mvn spring-boot:run
```
Expected: Application starts on port 8080

### Test API
```bash
# Health check
curl http://localhost:8080/

# Check if API is responding
curl http://localhost:8080/api/portfolios
```

## Common Issues & Solutions

### "Connection refused" error
- Ensure MySQL server is running
- Check credentials in application.yml
- Verify database exists: `SHOW DATABASES;`

### "Table doesn't exist" error
- Run schema.sql to create tables
- Check database name in connection URL

### Compilation errors
- Ensure Java 21 is set as JAVA_HOME
- Run `mvn clean compile -X` for debugging
- Check Maven dependencies: `mvn dependency:tree`

### Port already in use (8080)
- Change port in application.yml:
  ```yaml
  server:
    port: 8081
  ```

## Next Steps

1. **Database Setup**: Create MySQL database and tables
2. **Configure Credentials**: Update application.yml
3. **Build Project**: `mvn clean package`
4. **Run Application**: `mvn spring-boot:run`
5. **Test APIs**: Use curl or Postman
6. **Enhance Features**: Add business logic as needed

## Documentation

For detailed information, see [JDBC_IMPLEMENTATION.md](JDBC_IMPLEMENTATION.md)

---

**Implementation Status**: ✅ Complete  
**Java Version**: 21 LTS  
**Build Status**: ✅ Success  
**Database**: MySQL with JDBC Connectivity  

