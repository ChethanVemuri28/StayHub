# ADR-002: Apex vs Flow for Booking Rules

**Status:** Proposed  
**Date:** November 3, 2026  
**Decision Area:** Booking Business Logic

## 1. Context

StayHub supports hotel room bookings, including bookings containing multiple rooms.

The booking process involves several business rules:

- Check-out date must be later than check-in date.
- A room cannot have overlapping active bookings.
- Room occupancy cannot exceed the maximum permitted occupancy.
- A booking must contain at least one room.
- Booking totals must reflect the selected rooms and stay duration.
- Cancelled bookings must release room availability.
- Multiple booking requests must be handled safely.

The system needs a reliable approach to implement and maintain these rules.

## 2. Options

### Option A: Salesforce Flow

Implement booking rules using Screen Flows and Record-Triggered Flows.

Advantages:

- Declarative development.
- Easier for administrators to maintain.
- Visual representation of business processes.
- Suitable for simple validations and notifications.
- Faster implementation for straightforward automation.

Disadvantages:

- Complex room availability checks can become difficult to maintain.
- Complex processing across multiple rooms requires additional flow elements.
- Less control over transaction handling.
- Complex automation can become difficult to troubleshoot and optimize.

### Option B: Apex

Implement booking rules using Apex classes, triggers and service methods.

Advantages:

- Supports complex business logic.
- Provides Map and Set data structures.
- Supports bulk processing.
- Provides granular transaction control.
- Suitable for complex date-overlap calculations.
- Easier to centralize reusable booking validation logic.

Disadvantages:

- Requires development expertise.
- Requires Apex unit tests.
- Requires additional coding and deployment effort.
- More responsibility for code maintenance.

### Option C: Hybrid Approach

Use Apex for core booking rules and Flow for supporting automation.

Advantages:

- Complex logic remains in reusable Apex services.
- Declarative automation remains available for simpler workflows.
- Balances developer control and administrator maintainability.
- Supports separation of business logic and process orchestration.

Disadvantages:

- Requires clear boundaries between Flow and Apex.
- Requires coordination when both technologies participate in the same transaction.
- Additional architectural discipline is necessary.

## 3. Decision

**StayHub will use a hybrid approach, with Apex as the primary implementation for critical booking business rules.**

Apex will handle:

- Room availability validation.
- Date-overlap detection.
- Multi-room booking validation.
- Occupancy validation.
- Booking total calculations where complex processing is required.
- Transaction integrity and conflict handling.
- Bulk-safe processing.

Flow will be used for simpler supporting automation, such as:

- Booking confirmation notifications.
- Internal notifications.
- Straightforward status-based automation.
- Administrative processes.

A single clear automation entry point will be maintained for each object to avoid conflicting Flow and Apex automation.

## 4. Reasons

1. Room availability requires checking date ranges across existing bookings.
2. Multiple rooms can be associated with one booking.
3. Booking rules must be consistently enforced regardless of whether a booking originates from a guest interface, receptionist interface, or another integration.
4. Apex provides greater control over complex queries and transaction handling.
5. Flow remains useful for simpler automation and administrative processes.
6. The hybrid approach balances maintainability and technical flexibility.

## 5. Consequences

### Positive Consequences

- Centralized and reusable booking validation.
- Better control over complex business rules.
- Improved support for bulk operations.
- Easier unit testing of booking services.
- Separation between critical business logic and supporting automation.

### Negative Consequences

- More Apex development effort.
- Increased responsibility for unit testing and deployment.
- Developers must maintain clear documentation.
- Flow and Apex execution order must be managed carefully.

### Risks and Mitigations

| Risk                        | Mitigation                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------- |
| Concurrent booking requests | Revalidate availability during booking and implement appropriate concurrency controls |
| Governor-limit exceptions   | Bulkify SOQL and DML operations                                                       |
| Duplicate business logic    | Centralize booking rules in Apex services                                             |
| Flow and Apex recursion     | Maintain one entry point and document automation order                                |
| Insufficient test coverage  | Create positive, negative and bulk test scenarios                                     |

## 6. References

- Salesforce Record-Triggered Automation Decision Guide: https://architect.salesforce.com/docs/architect/decision-guides/guide/record-triggered.html
- Salesforce Apex Developer Guide: https://developer.salesforce.com/docs/platform/apex/guide
