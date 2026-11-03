<p align="center">
  <img src="images/stayhub-logo.png"
       alt="StayHub - Your Stay. Your Way."
       width="650"/>
</p>

<div align="center">

**Your Stay. Your Way.**

<h1>User Stories & Acceptance Criteria</h1>

<h2>Defining application requirements from the perspective of every StayHub user.</h2>

</div>

---

## 📌 Document Overview

| Property           | Details                              |
| ------------------ | ------------------------------------ |
| Project            | StayHub                              |
| Document           | User Stories and Acceptance Criteria |
| Version            | 1.0                                  |
| Status             | Draft                                |
| Total User Stories | 15                                   |
| User Groups        | Guest, Hotel Partner, Administrator  |

## 🧭 Navigation

- [Guest Stories](#-1-guest-user-stories)
- [Hotel Partner Stories](#-2-hotel-partner-user-stories)
- [Administrator Stories](#-3-administrator-user-stories)
- [Priority Summary](#-4-priority-summary)
- [Definition of Done](#-5-definition-of-done)

---

# 👤 1. Guest User Stories

Guests are users who visit StayHub to discover hotels, explore rooms, and manage reservations.

<details open>
<summary><strong>US-001 — Search Hotels</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to search for hotels by destination and stay dates so that I can discover accommodation options matching my travel plans.

**Acceptance Criteria**

- [ ] The guest can enter a destination.
- [ ] The guest can specify check-in and check-out dates.
- [ ] The system displays hotels matching the search criteria.
- [ ] The system validates that the check-out date is later than the check-in date.
- [ ] An appropriate message is displayed when no hotels match the search.

</details>

<details>
<summary><strong>US-002 — Filter Search Results</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to filter hotel search results by price, rating, and amenities so that I can find accommodation matching my preferences.

**Acceptance Criteria**

- [ ] The guest can filter hotels by price range.
- [ ] The guest can filter hotels by rating.
- [ ] The guest can filter hotels by available amenities.
- [ ] Multiple filters can be applied together.
- [ ] Search results update to reflect the selected filters.

</details>

<details>
<summary><strong>US-003 — View Hotel Details</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to view detailed hotel information so that I can evaluate a property before making a reservation.

**Acceptance Criteria**

- [ ] The guest can view the hotel name, description, and location.
- [ ] The guest can view available room types and their details.
- [ ] The guest can view hotel amenities and facilities.
- [ ] The guest can view available ratings and reviews.
- [ ] The system displays an appropriate message if hotel information is unavailable.

</details>

<details>
<summary><strong>US-004 — Check Room Availability</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to check room availability for my selected dates so that I can choose a room that can accommodate my stay.

**Acceptance Criteria**

- [ ] The guest can select check-in and check-out dates.
- [ ] The system identifies rooms available for the entire selected date range.
- [ ] The system excludes rooms already reserved for overlapping dates.
- [ ] The system displays an appropriate message when no rooms are available.
- [ ] Availability is revalidated before confirming a reservation.

</details>

<details>
<summary><strong>US-005 — Create a Booking</strong> · Priority: Critical · Week 3</summary>

**User Story**

As a guest, I want to reserve an available room so that I can secure accommodation for my planned trip.

**Acceptance Criteria**

- [ ] The guest can select an available room and provide the required booking information.
- [ ] The system validates the guest information and selected stay dates.
- [ ] The system verifies room availability before creating the booking.
- [ ] The system calculates the booking amount based on the applicable pricing rules.
- [ ] A booking record is created only after all required validations succeed.

</details>

<details>
<summary><strong>US-006 — Receive Booking Confirmation</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to receive confirmation after successfully creating a booking so that I have a record of my reservation.

**Acceptance Criteria**

- [ ] The system generates a unique booking reference.
- [ ] The guest can view the booking confirmation details.
- [ ] The confirmation includes hotel, room, and stay information.
- [ ] The confirmation displays the booking status and applicable amount.
- [ ] The system sends a confirmation notification through the configured notification channel.

</details>

<details>
<summary><strong>US-007 — Cancel a Booking</strong> · Priority: High · Week 3</summary>

**User Story**

As a guest, I want to cancel an eligible reservation so that I can manage changes to my travel plans.

**Acceptance Criteria**

- [ ] The guest can view their existing bookings.
- [ ] The guest can request cancellation of an eligible booking.
- [ ] The system validates the cancellation rules before processing the request.
- [ ] The booking status is updated to Cancelled after successful cancellation.
- [ ] The room becomes available again when applicable.
- [ ] The guest receives cancellation confirmation.

</details>

<details>
<summary><strong>US-008 — Submit Hotel Reviews</strong> · Priority: Medium · Week 4</summary>

**User Story**

As a guest, I want to submit a rating and review for a hotel so that I can share my experience with other travellers.

**Acceptance Criteria**

- [ ] The guest can select a rating within the configured rating scale.
- [ ] The guest can submit written feedback.
- [ ] The system validates that the rating is within the permitted range.
- [ ] Only eligible guests can submit reviews according to the configured review policy.
- [ ] Submitted reviews are associated with the relevant hotel.

</details>

<details>
<summary><strong>US-009 — Submit a Hotel Enquiry</strong> · Priority: Medium · Week 2</summary>

**User Story**

As a prospective guest, I want to submit an enquiry about a hotel so that I can receive additional information before making a booking.

**Acceptance Criteria**

- [ ] The guest can submit their name and contact information.
- [ ] The guest can select the hotel they are enquiring about.
- [ ] The guest can provide an enquiry message.
- [ ] The system validates required enquiry information.
- [ ] An enquiry or lead record is created and associated with the appropriate hotel.
- [ ] The enquiry can be reviewed by an authorized hotel partner or administrator.

</details>

---

# 🏨 2. Hotel Partner User Stories

Hotel partners are responsible for managing their hotel profiles, room inventory, and reservation information.

<details>
<summary><strong>US-010 — Manage Hotel Profile</strong> · Priority: High · Week 2</summary>

**User Story**

As a hotel partner, I want to create and update my hotel profile so that guests can view accurate information about my property.

**Acceptance Criteria**

- [ ] The hotel partner can create a hotel profile with required information.
- [ ] The hotel partner can update permitted hotel details.
- [ ] The system validates mandatory hotel information.
- [ ] The hotel partner can manage only authorized hotel records.
- [ ] Updated information is reflected in the hotel listing after the applicable publishing process.

</details>

<details>
<summary><strong>US-011 — Manage Room Types</strong> · Priority: High · Week 2</summary>

**User Story**

As a hotel partner, I want to create and manage room types so that guests can explore different accommodation options.

**Acceptance Criteria**

- [ ] The hotel partner can create room types for an authorized hotel.
- [ ] The partner can specify room type name, capacity, and description.
- [ ] The partner can update existing room type information.
- [ ] The system validates required room type information.
- [ ] Room types are associated with the correct hotel.

</details>

<details>
<summary><strong>US-012 — Manage Room Inventory</strong> · Priority: Critical · Week 3</summary>

**User Story**

As a hotel partner, I want to manage room inventory and room status so that StayHub displays accurate room availability.

**Acceptance Criteria**

- [ ] The hotel partner can create room records.
- [ ] The partner can update room information and permitted room statuses.
- [ ] Every room is associated with an appropriate hotel and room type.
- [ ] The system prevents invalid room inventory information.
- [ ] Room availability calculations consider existing bookings.

</details>

<details>
<summary><strong>US-013 — Manage Reservations</strong> · Priority: High · Week 4</summary>

**User Story**

As a hotel partner, I want to view and manage reservations for my property so that I can monitor upcoming guest stays.

**Acceptance Criteria**

- [ ] The hotel partner can view reservations belonging to authorized properties.
- [ ] The partner can view booking reference, guest details permitted by policy, and stay dates.
- [ ] The partner can view booking status.
- [ ] The system prevents access to reservations belonging to unauthorized hotels.
- [ ] Booking information reflects the latest reservation status.

</details>

---

# 🛡️ 3. Administrator User Stories

Administrators oversee platform operations, access, and data quality.

<details>
<summary><strong>US-014 — Manage User Access</strong> · Priority: Critical · Week 2</summary>

**User Story**

As a platform administrator, I want to manage user access and permissions so that users can access only the functionality and records appropriate to their roles.

**Acceptance Criteria**

- [ ] The administrator can view relevant user information.
- [ ] The administrator can assign or update authorized user permissions.
- [ ] The system enforces object-level and field-level security.
- [ ] The system enforces record-level access.
- [ ] Unauthorized users cannot access restricted functionality or records.

</details>

<details>
<summary><strong>US-015 — Monitor Platform Bookings</strong> · Priority: High · Week 4</summary>

**User Story**

As a platform administrator, I want to monitor hotel bookings across StayHub so that I can oversee platform activity and identify operational issues.

**Acceptance Criteria**

- [ ] The administrator can view authorized booking records across the platform.
- [ ] The administrator can filter bookings by status and stay dates.
- [ ] The administrator can view booking summary information.
- [ ] The system provides accurate booking counts and summaries.
- [ ] Access to administrative monitoring functionality is restricted to authorized users.

</details>

---

# 📊 4. Priority Summary

| Priority | Meaning                             | Stories |
| -------- | ----------------------------------- | ------: |
| Critical | Essential for core operations       |       3 |
| High     | Important for primary user journeys |      10 |
| Medium   | Supporting functionality            |       2 |

### Stories by User Group

| User Group    | Story IDs            |  Count |
| ------------- | -------------------- | -----: |
| Guest         | US-001 to US-009     |      9 |
| Hotel Partner | US-010 to US-013     |      4 |
| Administrator | US-014 to US-015     |      2 |
| **Total**     | **US-001 to US-015** | **15** |

### Planned Development Distribution

| Week   | Planned Focus                                                            | Stories                        |
| ------ | ------------------------------------------------------------------------ | ------------------------------ |
| Week 2 | Lead capture, hotel profile, room types, access                          | US-009, US-010, US-011, US-014 |
| Week 3 | Search, filters, details, availability, booking, cancellation, inventory | US-001 to US-007, US-012       |
| Week 4 | Reviews, reservations, administration                                    | US-008, US-013, US-015         |

---

# ✅ 5. Definition of Done

A user story is considered complete only when all applicable conditions are satisfied.

- [ ] Implementation matches the agreed acceptance criteria.
- [ ] Apex and/or LWC code follows Salesforce best practices.
- [ ] Appropriate unit tests are written and pass.
- [ ] CRUD, FLS, and sharing requirements are validated.
- [ ] Code Analyzer checks are completed.
- [ ] Changes are committed to the appropriate Git branch.
- [ ] Pull request review is completed.
- [ ] Deployment validation succeeds.
- [ ] Reviewer acceptance is recorded.

---

## 🔗 DevOps Center Work Item Mapping

Each user story will be represented by a corresponding DevOps Center work item.

| Field               | Expected Value                              |
| ------------------- | ------------------------------------------- |
| Work Item Title     | User Story ID and short title               |
| Description         | Complete user story                         |
| Acceptance Criteria | Testable conditions from this document      |
| Priority            | Critical / High / Medium                    |
| Planned Week        | Assigned development week                   |
| Status              | New / In Progress / Ready for Review / Done |

---

<div align="center">

**StayHub — Your Stay. Your Way.**

_Building better hotel experiences, one user story at a time._

</div>
