# StayHub – Dev to Staging Promotion Guide

**Purpose:** Standard procedure for promoting Salesforce metadata changes from Development to Staging using Lifecycle Center.

**Promotion Flow:** Development → Integration → UAT → Staging

## 1. Development & Commit

1. Create a work item in Lifecycle Center and assign it to the developer.
2. Select the connected Development environment and mark the work item **In Progress**.
3. Implement and test the required metadata changes in the Development org.
4. Open **DX Inspector → Change Management**.
5. Select the modified metadata components and click **Commit Options**.
6. Select the StayHub project and corresponding work item.
7. Enter a meaningful commit message and click **Commit**.
8. Verify that the components appear in the work item's **Change List**.

## 2. Review & Approval

1. In DX Inspector, create a review for the work item.
2. Open the generated GitHub pull request.
3. Review the source branch, target branch, commits, and changed files.
4. Confirm that only the intended changes are included.
5. Approve the pull request.
6. Return to Lifecycle Center and select **Mark as Ready to Promote**.

**Note:** Do not manually merge Lifecycle Center-generated pull requests. Lifecycle Center handles merging during promotion.

## 3. Promote Through the Pipeline

Promote the work item sequentially through these stages:

| Source | Destination |
|---|---|
| Development | Integration |
| Integration | UAT |
| UAT | Staging |

For each promotion:

1. Open the StayHub Pipeline.
2. Select the work item or click **Promote Stage**, as appropriate.
3. Select **Promote Now**.
4. Choose **Only changes missing from [Destination]**.
5. Select the appropriate Apex test option based on the changes being deployed.
6. Click **Promote**.
7. Verify deployment success before proceeding to the next stage.

## 4. Final Verification

1. Confirm that the work item appears in the Staging stage.
2. Log in to the Staging Salesforce org.
3. Verify that the deployed metadata exists and has the expected configuration.
4. Confirm successful deployment in Lifecycle Center.

## Important Guidelines

- Follow the promotion sequence: Integration → UAT → Staging.
- Resolve deployment errors before proceeding.
- Prefer **Only changes missing from destination**.
- Do not promote to Production without the required release approval.

**Completion Criteria:** The work item is successfully promoted to Staging, and all intended metadata changes are verified.