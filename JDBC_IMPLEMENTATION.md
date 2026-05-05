# Resume to Portfolio Builder - JDBC Implementation Guide

## Overview

This document describes the Java and JDBC connectivity implementation for the Resume to Portfolio Builder application. The implementation provides a complete data persistence layer using raw JDBC with Spring Framework.

## Architecture

### Technology Stack
- **Java Runtime**: Java 21 LTS
- **Framework**: Spring Boot 3.2.3
- **Database**: MySQL 8.0+
- **Data Access**: JDBC (Java Database Connectivity)
- **Connection Pooling**: HikariCP (included with Spring Boot)
- **Build Tool**: Maven 3.9.15

### Project Structure

```
src/main/java/com/portfoliobuilder/
├── model/
│   ├── User.java           # User entity model
│   ├── Resume.java         # Resume entity model
│   └── Portfolio.java      # Portfolio entity model
├── dao/
│   ├── UserDAO.java        # User data access object
│   ├── ResumeDAO.java      # Resume data access object
│   └── PortfolioDAO.java   # Portfolio data access object
├── service/
│   ├── UserService.java           # User business logic
│   ├── ResumeService.java         # Resume business logic
│   └── PortfolioService.java      # Portfolio business logic
├── controller/
│   ├── UploadController.java      # File upload & resume endpoints
│   ├── UserController.java        # User management endpoints
│   ├── PortfolioController.java   # Portfolio management endpoints
│   └── WebController.java         # Web page routing
├── config/
│   └── DatabaseConfig.java        # Database configuration
└── Application.java               # Main Spring Boot application

resources/
├── application.yml         # Application configuration
└── schema.sql             # Database schema initialization
```

## Data Models

### User Entity
- **user_id**: Primary key (auto-incremented)
- **username**: Unique username
- **email**: Unique email address
- **full_name**: User's full name
- **password**: Hashed password (optional for OAuth)
- **oauth_provider**: OAuth provider name (e.g., "github")
- **oauth_id**: OAuth provider's user ID
- **created_at**: Timestamp of account creation
- **updated_at**: Timestamp of last update

### Resume Entity
- **resume_id**: Primary key (auto-incremented)
- **user_id**: Foreign key to users table
- **filename**: Stored filename with timestamp
- **original_filename**: Original filename from upload
- **file_type**: MIME type (e.g., "application/pdf")
- **file_size**: Size in bytes
- **file_content**: Binary file data (LONGBLOB)
- **status**: Upload status (UPLOADED, PARSED, etc.)
- **uploaded_at**: Upload timestamp
- **parsed_at**: Parsing completion timestamp (nullable)

### Portfolio Entity
- **portfolio_id**: Primary key (auto-incremented)
- **user_id**: Foreign key to users table
- **resume_id**: Foreign key to resumes table
- **portfolio_title**: Portfolio title
- **portfolio_html**: Generated HTML content (LONGTEXT)
- **portfolio_url**: Public portfolio URL
- **status**: Generation status (GENERATED, PUBLISHED, etc.)
- **created_at**: Creation timestamp
- **updated_at**: Last update timestamp

## Database Setup

### 1. Create Database and Tables

Run the schema.sql file to create the database and tables:

```bash
mysql -u root -p < src/main/resources/schema.sql
```

Or execute manually in MySQL client:

```sql
CREATE DATABASE portfolio_builder DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE portfolio_builder;

-- Run commands from schema.sql
```

### 2. Database Configuration

Update `application.yml` with your MySQL credentials:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/portfolio_builder?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
    username: root          # Change to your MySQL username
    password: root          # Change to your MySQL password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
```

## JDBC Implementation Details

### DAO Layer (Data Access Object)

The DAO layer implements raw JDBC operations for database access:

#### UserDAO
- `createUser()`: Insert new user
- `getUserById()`: Retrieve user by ID
- `getUserByEmail()`: Retrieve user by email
- `getUserByOAuth()`: Retrieve user by OAuth provider and ID
- `getAllUsers()`: Retrieve all users
- `updateUser()`: Update user information
- `deleteUser()`: Delete user account
- `userExists()`: Check if user exists
- `emailExists()`: Check if email already registered

#### ResumeDAO
- `createResume()`: Store uploaded resume with file content
- `getResumeById()`: Retrieve resume by ID
- `getResumesByUserId()`: Retrieve all resumes for a user
- `getAllResumes()`: Retrieve all resumes
- `updateResumeStatus()`: Update resume processing status
- `deleteResume()`: Delete resume
- `deleteResumesByUserId()`: Delete all resumes for a user
- `getResumeCountByUserId()`: Count resumes per user

#### PortfolioDAO
- `createPortfolio()`: Create generated portfolio record
- `getPortfolioById()`: Retrieve portfolio by ID
- `getPortfoliosByUserId()`: Retrieve user's portfolios
- `getPortfoliosByResumeId()`: Retrieve portfolios generated from a resume
- `getAllPortfolios()`: Retrieve all portfolios
- `updatePortfolio()`: Update portfolio content/status
- `deletePortfolio()`: Delete portfolio
- `deletePortfoliosByUserId()`: Delete user's portfolios
- `getPortfolioCountByUserId()`: Count portfolios per user

### JDBC Features Used

1. **PreparedStatement**: Prevents SQL injection
   ```java
   PreparedStatement ps = con.prepareStatement(sql);
   ps.setInt(1, userId);
   ps.setString(2, email);
   ```

2. **RowMapper**: Maps ResultSet rows to Java objects
   ```java
   User user = jdbcTemplate.queryForObject(sql, userRowMapper);
   ```

3. **Connection Pooling**: HikariCP for connection management
   ```yaml
   hikari:
     maximum-pool-size: 10
     minimum-idle: 5
   ```

4. **Transaction Management**: Spring-managed transactions (optional)

5. **Auto-generated Keys**: Retrieves inserted IDs
   ```java
   KeyHolder keyHolder = new GeneratedKeyHolder();
   jdbcTemplate.update(preparedStatementCreator, keyHolder);
   ```

## REST API Endpoints

### User Management (`/api/users`)
- `GET /api/users/profile` - Get current user profile
- `GET /api/users/{userId}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{userId}` - Update user
- `DELETE /api/users/{userId}` - Delete user

### Resume Management (`/api`)
- `POST /api/upload` - Upload resume file
- `GET /api/resumes` - Get user's resumes
- `GET /api/resume/{resumeId}` - Get resume details
- `DELETE /api/resume/{resumeId}` - Delete resume

### Portfolio Management (`/api/portfolios`)
- `POST /api/portfolios` - Create portfolio
- `GET /api/portfolios/{portfolioId}` - Get portfolio by ID
- `GET /api/portfolios/user/{userId}` - Get user's portfolios
- `GET /api/portfolios/resume/{resumeId}` - Get portfolios from resume
- `PUT /api/portfolios/{portfolioId}` - Update portfolio
- `DELETE /api/portfolios/{portfolioId}` - Delete portfolio
- `GET /api/portfolios` - Get all portfolios

## Example Usage

### 1. Upload Resume

```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -F "resume=@resume.pdf" \
  http://localhost:8080/api/upload
```

Response:
```json
{
  "status": "success",
  "resumeId": 1,
  "filename": "1234567890_resume.pdf",
  "fileSize": 102400,
  "uploadedAt": 1703001600000
}
```

### 2. Get User Resumes

```bash
curl -X GET \
  -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/resumes
```

Response:
```json
{
  "status": "success",
  "resumes": [
    {
      "resumeId": 1,
      "userId": 1,
      "filename": "1234567890_resume.pdf",
      "originalFilename": "resume.pdf",
      "status": "UPLOADED",
      "uploadedAt": "2026-04-28T02:08:00"
    }
  ],
  "count": 1
}
```

### 3. Create Portfolio

```bash
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "resumeId": 1,
    "portfolioTitle": "My Portfolio",
    "portfolioHtml": "<html>...</html>",
    "portfolioUrl": "https://portfolio.example.com"
  }' \
  http://localhost:8080/api/portfolios
```

## Security Considerations

1. **SQL Injection Prevention**: All queries use PreparedStatement
2. **OAuth2 Integration**: Secure authentication via GitHub OAuth2
3. **Password Security**: Store hashed passwords (use bcrypt in production)
4. **Connection Security**: 
   - Use SSL/TLS for database connections in production
   - Update `allowPublicKeyRetrieval` setting appropriately
5. **Data Validation**: Input validation at service layer
6. **Error Handling**: Generic error messages to prevent information leakage

## Performance Optimization

1. **Connection Pooling**: HikariCP with configurable pool size
2. **Indexes**: Database indexes on frequently queried columns:
   - users.email, users.oauth_provider
   - resumes.user_id, resumes.status
   - portfolios.user_id, portfolios.resume_id
3. **Prepared Statements**: Reusable query plans
4. **Lazy Loading**: File content retrieved only when needed

## Transaction Management

Current implementation uses Spring's implicit transaction management. For explicit control:

```java
@Transactional
public void complexOperation() {
    // Multiple JDBC operations
}
```

## Troubleshooting

### Connection Issues
- Verify MySQL is running: `mysql -u root -p`
- Check database exists: `SHOW DATABASES;`
- Verify credentials in application.yml

### Compilation Errors
- Ensure Java 21 is set as JAVA_HOME
- Run `mvn clean compile` to rebuild
- Check for deprecated API warnings

### SQL Errors
- Review schema.sql for correct table definitions
- Check foreign key constraints
- Verify JDBC driver version compatibility

## Future Enhancements

1. **JPA/Hibernate Migration**: Consider ORM for complex queries
2. **Caching Layer**: Redis for frequently accessed data
3. **Batch Operations**: Bulk inserts for improved performance
4. **Event Sourcing**: Track portfolio generation events
5. **Audit Logging**: Track all data modifications
6. **Replication**: Master-slave database replication
7. **Connection Monitoring**: Add metrics and monitoring

## Building and Running

### Build
```bash
mvn clean package
```

### Run
```bash
mvn spring-boot:run
```

### Run Tests
```bash
mvn test
```

## Dependencies

- **spring-boot-starter-web**: Web framework
- **spring-boot-starter-security**: Security framework
- **spring-boot-starter-oauth2-client**: OAuth2 client
- **spring-boot-starter-jdbc**: JDBC support
- **mysql-connector-java**: MySQL JDBC driver

## Version Information

- Java: 21 LTS
- Spring Boot: 3.2.3
- Maven: 3.9.15
- MySQL: 8.0+
- MySQL Connector/J: 8.0.32

---

**Last Updated**: April 28, 2026  
**Implementation Status**: Complete
