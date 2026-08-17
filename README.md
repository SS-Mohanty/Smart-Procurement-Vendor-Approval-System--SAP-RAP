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

## 4. Future Enhancements 
 - Row-Level Security (DCL): Implementing SAP Data Control Language (DCL) to enforce PFCG role-based authorizations, ensuring managers can only query requisitions tied to their specific department/cost center.

 - Virtual Elements: Utilizing the if_sadl_exit_calc_element_read interface to calculate dynamic, transient UI fields at runtime (e.g., live "Days Pending" or "Budget Variance" counters) without persisting them in the HANA database.

 - Test-Driven Development (TDD): Building automated ABAP Unit Tests leveraging the RAP BO Test Double Framework (CL_ABAP_BEHV_TEST_ENVIRONMENT) to validate the state machine without UI dependencies.

 - Dynamic Tender & Budget Logic: Extending the backend data model and determinations to calculate remaining departmental budgets against the active tender amount, dynamically locking approvals if budgets are exceeded.

- Analytical Dashboards: Deploying an SAP Fiori Analytical List Page (ALP) utilizing @Analytics.query: true CDS annotations to visualize real-time procurement spending trends.

- REST-Driven Event Notifications: Bypassing native cloud SMTP restrictions by integrating a custom HTTP client class to trigger external REST-based email APIs (e.g., SendGrid) for immediate vendor and manager alerts, if BTP trail allows.

---------------------------------------------------------


## 5. System Flowchart (Requisition-to-Approval Lifecycle)

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
