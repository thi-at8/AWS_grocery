# Infrastructure Documentation

This folder contains a transparent and reproducible description of the technical infrastructure used by this project.

The infrastructure is defined using **Infrastructure-as-Code (IaC)** principles.  
This means the technical setup is documented in a clear, version-controlled way instead of being configured manually.

---

## Purpose of this folder

The goal of this folder is **documentation and transparency**.

It allows:
- reviewers to understand how the system is structured
- partners to assess technical feasibility
- developers to reproduce the setup if required

Viewing this folder does **not** deploy or modify any systems.

---

## What is documented here

The infrastructure definition includes:

- **Application Server (EC2)**  
  A virtual server that hosts the application logic.

- **Security Rules (Security Groups)**  
  Firewall rules that control which network traffic is allowed.

- **Database (RDS)**  
  A managed relational database used by the application.

---

## What is intentionally NOT included

For security and data protection reasons, the following elements are excluded:

- Passwords, API keys, or credentials  
- Infrastructure state files  
- Local caches or provider binaries  

These elements are generated locally during deployment and must never be shared publicly.

---

## Why this approach is used

Using Infrastructure-as-Code ensures:

- **Transparency** – the setup can be reviewed at any time  
- **Reproducibility** – the infrastructure can be recreated reliably  
- **Auditability** – changes are tracked via version control  

This approach is commonly used in professional, public-sector, and funded projects.

---

## Simple Architecture Overview

![Simple architecture overview](architecture.png)

This diagram illustrates the basic structure of the system:
- users access the application via the internet
- the application runs on a server
- data is stored in a separate database

No direct access to the database from the internet is possible.

