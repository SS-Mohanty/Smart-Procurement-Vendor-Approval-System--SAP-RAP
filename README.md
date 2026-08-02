# Smart-Procurement-Vendor-Approval-System--SAP-RAP
Cloud-native enterprise procurement workflow application built with SAP ABAP Cloud RAP (Managed Scenario), OData V4, CDS View Entities, and Fiori Elements, featuring role-based state machine validations, automated determinations, and secure EML audit logging.


-------------------------------------------------------------------------------------------------------------------------------------------------------------

## 1. Executive Summary & Business Context
Enterprise procurement requires rigid state machine controls to prevent unauthorized purchasing, automated tracking of costs, and rigorous audit trails for compliance. This application automates the end-to-end requisition-to-approval lifecycle—from initial draft creation by general procurement staff to final managerial sign-off and vendor assignment, complete with immutable historical logging.

-------------------------------------------------------------------------------------------------------------------------------------------------

## 2. End-to-End Functional Workflow
The application governs procurement requests through a strict lifecycle state machine. 

### Lifecycle States
* **`NEW` (Draft/Initial):** Requisition is created, line items are added, and calculations are computed dynamically.
* **`PENDING` (Submitted):** Locked from direct user edits; submitted to management/approvers.
* **`APPROVED` / `REJECTED`:** Managerial review outcome. Approved requests proceed to vendor assignment.
* **`COMPLETED`:** Final state once the vendor is assigned and the order is closed.

---

## Architecture & Technical Highlights

* **Backend Core Architecture:** Built using the managed RAP scenario with persistent database tables (`zproj_pr_hdr`, `zproj_pr_item`), draft handling, and framework-managed UUID numbering.
* **State Machine & Instance Features:** Dynamic UI action control (`Submit`, `Approve`, `Reject`, `AssignVendor`, `Complete`) based on request lifecycle statuses (`NEW`, `PENDING`, `APPROVED`, `REJECTED`, `COMPLETED`).
* **Automated Business Logic:** 
  * Real-time local timestamp generation.
  * Automated sequential identifier logic.
  * Dynamic total cost calculation on line item modifications via Entity Manipulation Language (EML) lookups.
* **Enterprise Audit Logging:** Leverages `with additional save` and a custom saver implementation to record immutable event audit trails into `zproj_appr_hist` upon every workflow state change.
* **User Interface:** Developed using SAP Fiori Elements List Report and Object Page layouts with value help definitions, role-based associations, and customized header branding.

---

## Project Object Structure

* **Data Model:** CDS View Entities for Headers, Items, and Approval History.
* **Behavior Definition:** Managed behavior definition with locks, drafts, validations, and determinations.
* **Business Logic:** Behavior implementation classes (`.clas.abap`) handling validation actions and saver hooks.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------




## 3. System Flowchart (Requisition-to-Approval Lifecycle)

```text
 [ User / Requester ]
         │
         ▼ (Create Draft & Add Items)
   ┌───────────┐
   │   NEW     │ ──(Dynamic EML Total Calculation)
   └─────┬─────┘
         │
         ▼ (Trigger Action: Submit)
   ┌───────────┐
   │  PENDING  │ ──(Locks instance rows, prevents direct edits)
   └─────┬─────┘
         │
         ├──────────────────────────────┐
         ▼ (Manager Action: Approve)    ▼ (Manager Action: Reject)
   ┌───────────┐                  ┌───────────┐
   │ APPROVED  │                  │ REJECTED  │
   └─────┬─────┘                  └───────────┘
         │
         ▼ (Assign Vendor & Complete)
   ┌───────────┐
   │ COMPLETED │
   └─────┬─────┘
         │
         ▼ (with additional save)
   [ Immutable Audit Log Table: zproj_appr_hist ]
