# Customer 360 Analytics Platform

## 🚀 Overview
A comprehensive data analytics platform that integrates customer data from multiple sources to deliver a unified 360-degree customer view for advanced business intelligence and decision-making.

---

## 🎯 Objective
To build a centralized analytics system to:
- Provide a single source of truth for customer data
- Improve customer experience through data-driven insights
- Enhance marketing effectiveness and customer service

---

## 🧱 Architecture

The solution follows a **modern layered architecture**:

1. **Data Ingestion Layer (Bronze)**
   - Tool: Azure Data Factory (ADF)
   - Sources: Online transactions, in-store purchases, CRM, and loyalty program

2. **Data Storage Layer (Silver)**
   - Tool: Azure Data Lake Storage Gen2 (ADLS)
   - Structure: `/raw/`, `/processed/`

3. **Data Processing Layer (Gold)**
   - Tool: Azure Synapse Analytics
   - Logic: Views, transformations, validations, Customer 360 metrics

4. **Data Consumption Layer**
   - Tool: Power BI
   - Outputs: Interactive dashboards and visual reports

![Architecture Diagram](architecture.png)

---

## ⚙️ Technologies Used
- Azure Data Factory
- Azure Data Lake Storage Gen2
- Azure Synapse Analytics
- Power BI

---

## 📁 Project Structure

