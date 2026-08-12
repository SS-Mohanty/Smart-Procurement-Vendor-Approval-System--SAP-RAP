#  Smart Procurement Vendor Approval System (SAP RAP)

> **Cloud-native enterprise procurement workflow application built with SAP ABAP Cloud, RAP (RESTful ABAP Programming Model), OData V4, and SAP Fiori Elements.**

## 1. Executive Summary & Business Context
In large enterprises, procurement requires rigid state machine controls to prevent unauthorized purchasing, automated tracking of costs, and rigorous audit trails for compliance. 

This application automates the end-to-end requisition-to-approval lifecycle. Moving beyond a simple CRUD application, this system enforces **Role-Based Access Control (RBAC)** through multi-persona UI projections, strict lifecycle state machines via dynamic feature control, and an immutable, EML-driven audit log to ensure total financial compliance.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 2. Key Enterprise Features

*  **Multi-Persona Architecture (RBAC):** Three isolated Fiori Elements applications (Employee, Manager, Procurement Officer) powered by distinct CDS Projection Views to ensure strict functional data isolation.
*  **Strict State Machine & Feature Control:** Dynamic UI action control (`Submit`, `Approve`, `Reject`, `AssignVendor`, `Complete`). Buttons and edit capabilities are dynamically locked/rendered based on the exact lifecycle status of the request.
*  **Parameterized Actions:** Implementation of abstract CDS entities to trigger native Fiori dialog popups (e.g., capturing mandatory "Rejection Reasons" directly from the Manager).
*  **Immutable Audit Logging (EML):** Bypasses standard SQL and Late Savers to utilize native **Entity Manipulation Language (EML)**. This ensures every status change, actor, and timestamp is logged securely alongside the RAP draft framework.
*  **Modern External Integrations:**
  * **REST APIs:** Dynamic generation of vendor UPI payment URLs converted into live QR codes via external API injection.
  * **Binary File Generation:** ABAP string-to-binary (`XSTRING`) conversions to dynamically generate and attach downloadable `.txt` procurement vouchers.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 3. Technical Stack & Architecture

* **Backend Core:** SAP ABAP Cloud, RAP Managed Scenario, OData V4.
* **Database:** SAP HANA (persistent tables `zproj_pr_hdr`, `zproj_pr_item`, `zproj_appr_hist`).
* **Keys & Numbering:** Framework-managed UUIDs combined with automated semantic ID determinations (e.g., `PR-2026-0001`).
* **Frontend:** SAP Fiori Elements (List Report & Object Page), Metadata Extensions (`.ddlx`).

----------------------------------------------------------------------------------------------------------------------------------------------------------

## 4. System Flowchart (Requisition-to-Approval Lifecycle)

```text
 [ EMPLOYEE PERSONA ]
         │
         ▼ (Create Draft & Add Items)
   ┌───────────┐
   │   NEW     │ ──(Determinations: Dynamic Total Cost & ID Generation)
   └─────┬─────┘
         │
         ▼ (Action: Submit) ──> [ EML logs "SUBMIT" to zproj_appr_hist ]
   ┌───────────┐
   │  PENDING  │ ──(Locks instance rows; Edit capabilities disabled)
   └─────┬─────┘
         │
 [ MANAGER PERSONA ]
         │
         ├──────────────────────────────┐
         ▼ (Action: Approve)            ▼ (Action: Reject) ──> [ Triggers Parameterized Popup for Reason ]
   ┌───────────┐                  ┌───────────┐
   │ APPROVED  │                  │ REJECTED  │ ──> [ Returns to Employee Queue ]
   └─────┬─────┘                  └───────────┘
         │                              │
         │                              ▼
         │                        [ EML logs Reason to zproj_appr_hist ]
 [ OFFICER PERSONA ]
         │
         ▼ (Action: Assign Vendor) ──> [ Generates UPI QR Code ]
   ┌─────────────────┐
   │ VENDOR ASSIGNED │ 
   └─────┬───────────┘
         │
         ▼ (Action: Generate Receipt) ──> [ ABAP converts String to XSTRING (.txt) ]
   ┌───────────────┐
   │ RECEIPT READY │ 
   └─────┬─────────┘
         │
         ▼ (Action: Complete)
   ┌───────────┐
   │ COMPLETED │ ──> [ Record is locked permanently ]
   └───────────┘
         │
         ▼
[ Immutable Audit Log Table: zproj_appr_hist ]


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
