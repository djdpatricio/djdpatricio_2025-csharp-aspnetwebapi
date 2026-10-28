# 💻 Sample project showcasing a basic API implementation for an Insurance Management System.

This is a practice and learning project built with C# and ASP.NET Core Web API, focused on the core structure of an Insurance Management System.

It demonstrates essential concepts in modern API development, including layered architecture, clean coding standards, and key features like authentication, data handling, and policy management.

Designed for experimentation and foundational training, this project serves as a starting point for developing more robust, production-ready insurance applications.

---

## 🔥 Tech Stack & Tools

<p>
    <img src="https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=c-sharp&logoColor=white" alt="C#" />
    <img src="https://img.shields.io/badge/ASP.NET-512BD4?style=for-the-badge&logo=dot-net&logoColor=white" alt="ASP.NET" />
    <img src="https://img.shields.io/badge/Microsoft_SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white" alt="MS SQL" />
    <img src="https://img.shields.io/badge/Web_API-007ACC?style=for-the-badge&logo=dot-net&logoColor=white" alt="Web API" />
    <img src="https://img.shields.io/badge/REST_API-007ACC?style=for-the-badge&logo=rest&logoColor=white" alt="REST API" />
    <img src="https://img.shields.io/badge/MVC-007ACC?style=for-the-badge&logo=dot-net&logoColor=white" alt="MVC" />
    <img src="https://img.shields.io/badge/ADO.NET-007ACC?style=for-the-badge&logo=microsoft&logoColor=white" alt="ADO.NET" />
    <img src="https://img.shields.io/badge/xUnit-8B0000?style=for-the-badge&logo=xunit&logoColor=white" alt="Xunit Tests" />
    <img src="https://img.shields.io/badge/Swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=black" alt="Swagger" />
    <img src="https://img.shields.io/badge/Visual_Studio-5C2D91?style=for-the-badge&logo=visual-studio&logoColor=white" alt="Visual Studio" />
    <img src="https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white" alt="VS Code" />
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
</p>

---

## ✨ Features

### 🧱 API & Service Foundations
- **Architectural Principles:** Layered Architecture, Object-Oriented Programming (OOP), SOLID Principles  
- **Core API Design:** Dependency Injection, API Versioning, JWT Authentication, Request Validation, CORS Handling

### 🗄️ Data Management & Interaction
- **Database Abstraction:** DB Wrapper, API DB Factory Wrapper  
- **Database Design & Structure:**
  - **Schema & Constraints:** Primary Keys, Foreign Keys, Normalization, Column/Field Standardization  
  - **Programmability:** Stored Procedures, Functions, Views, Procedure Return Results  
  - **Performance & Efficiency:** Query Optimization, Pagination, Indexing, UTC Time Saving

### ⚙️ Operational Excellence
- **Monitoring & Reliability:** API Logging, Timeout Handling

### 🧼 Code Quality & Standards
- **Development Practices:** Clean Code, Maintainability First  
- **Resource Management:** Constants, Static Data, Static Messages

### 🧪 Development Workflow & Testing
- **Documentation & Testing:** API Documentation, Unit Tests, Mock Data for Testing  
- **Deployment Readiness:** Docker Prepared

---

## 📚 Modules

1. 🧑‍💼 Agents  
2. 🧑‍💼 Sub-Agents  
3. 📣 Promo Managers  
4. 📊 Sales Managers  
5. 🕵️ Promo Officers  
6. 🤝 Partners  
7. 👤 Clients  
8. 🏢 Providers  
9. 🔀 Distribution Channels  
10. 🗂️ Product Categories  
11. 📦 Products  
12. 📘 **Policy Components:**
  - 💠 Benefits  
  - 🛡️ Deductibles  
  - 💰 Premiums  
  - 👨‍👩‍👧 Beneficiary  
  - 💳 Payments  
  - 📎 Attachments  
13. 🔄 **Policy Booking CRUD Operations:**
  - 🧾 Individual Policy Booking  
  - 🏢 Partner Policy Booking  
  - 👥 Group Policy Booking  

---

## 🛠 Requirements

- .NET Framework 8.0 or Higher
- MS SQL Server 16.0 or Higher
- Visual Studio

---

## 🔑 Default Authentication

> You can decode and verify this JWT at [jwt.io](https://jwt.io/)

### 📌 Header

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### 📦 Payload

```json
{
  "sub": "500329",
  "name": "John Doe",
  "role": "Sales Agent",
  "iss": "http://localhost:7175",
  "aud": "mc.ims.api",
  "exp": 1893456000
}
```

### ✍️ Signature

```
83afd726d5595c1eb62f0e5c839f52581b6ad0d13e4c6087ca8b764ab2c8409b
2401240e69236d1ef65bf76fa22ad731d8e252d585de3369c5b5545bdf9a6e6d
```

---


## ▶️ How to Run

1. Clone the repo:
   ```bash
   git clone https://github.com/MasterConnoisseurs/mc-2025-csharp-aspnetwebapi.git
   ```
2. Execute Database Script : [Database Script](https://drive.google.com/file/d/1bL9LIgujCLSs3MZQkQekZy_g3EjnZw7i/view?usp=sharing) 📄
3. Update the connection string to match your connection details.
  ```json
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=mc_ims;TrustServerCertificate=True;Trusted_Connection=True;"
  },
  ```

---

## 🖼️ Gallery

Here are some screenshots of the DJDPatricio Laundry Shop Application in action:

<p>
    <img src="https://drive.google.com/uc?export=download&id=1AvjtGaZGrjabZKaB-N11x63XmdVwP6G4" alt="system_image_1" width="500" />
    <img src="https://drive.google.com/uc?export=download&id=1AFOS19xB-GtPjtwqcjdseG8gts5GXdkI" alt="system_image_2" width="500"/>
    <img src="https://drive.google.com/uc?export=download&id=1uOXVhFWCIssB1Sa4IkzYKfV5xjtyaPeS" alt="system_image_3" width="500" />
    <img src="https://drive.google.com/uc?export=download&id=1D23hVV_071cLa84xDgJUD0Q0rt0xWkpm" alt="system_image_4" width="500"/>
    <img src="https://drive.google.com/uc?export=download&id=157hUs6yg-pw5pvoww_z8ObaWpSYi-gvB" alt="system_image_5" width="500"/>
    <img src="https://drive.google.com/uc?export=download&id=1UPVYeYDfJh_AoU7pvx0sPvsbcNqOQwvr" alt="system_image_6" width="500"/>
    <img src="https://drive.google.com/uc?export=download&id=1g9_o0HMXUu8ov-ICJbpTxWJbbyL1LNra" alt="system_image_7" width="500"/>
</p>


