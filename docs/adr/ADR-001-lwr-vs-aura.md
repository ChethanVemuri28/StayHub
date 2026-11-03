# ADR-001: LWR vs Aura for Experience Cloud

**Status:** Proposed  
**Date:** November 3, 2026  
**Decision Area:** Experience Cloud Architecture

## 1. Context

StayHub requires a customer-facing booking experience and a hotel-partner portal.

The platform must support:

- Public hotel browsing and room searches.
- Guest registration and booking management.
- Hotel receptionist access to hotel-specific bookings.
- Custom Lightning Web Components (LWC).
- Responsive user interfaces.
- Good page-load performance and scalability.

Salesforce Experience Cloud supports multiple frameworks, including Lightning Web Runtime (LWR) and Aura.

The architecture must select a framework that supports StayHub's requirements while remaining maintainable and scalable.

## 2. Options

### Option A: Aura Framework

Build the Experience Cloud site using an Aura-based template.

Advantages:

- Supports Aura components and Lightning Web Components.
- Provides several established out-of-the-box pages and components.
- Offers more built-in features in certain Experience Cloud scenarios.

Disadvantages:

- Older component framework.
- Less aligned with a new LWC-first architecture.
- Some features and components are specific to Aura.

### Option B: Lightning Web Runtime (LWR)

Build the Experience Cloud site using an LWR template.

Advantages:

- Designed around Lightning Web Components.
- Lightweight architecture.
- Designed for performance and scalability.
- Supports modern web development practices.
- Suitable for customized customer-facing experiences.

Disadvantages:

- Some standard Aura template components and pages are unavailable.
- Requires more custom development for certain features.
- Some Lightning component library features have different availability.

## 3. Decision

**StayHub will use Lightning Web Runtime (LWR) as the preferred Experience Cloud framework.**

The implementation will use Lightning Web Components for custom booking, hotel search, guest and receptionist interfaces.

Aura will remain an alternative if a required Experience Cloud feature or integration cannot be supported adequately by LWR.

## 4. Reasons

1. LWR aligns with StayHub's LWC-based development approach.
2. Performance and scalability are important for a public-facing hotel booking platform.
3. LWR supports modern web development practices.
4. Custom components provide flexibility for hotel search and booking workflows.
5. A common LWC-oriented architecture reduces dependence on multiple component frameworks.

## 5. Consequences

### Positive Consequences

- Modern and lightweight application architecture.
- Better alignment with LWC development.
- Flexibility to create customized booking experiences.
- Performance-oriented foundation for future growth.

### Negative Consequences

- Some standard Aura features may require custom implementation.
- Additional development effort may be required.
- The team must verify component and template compatibility before implementation.

### Risks and Mitigations

| Risk                                    | Mitigation                                       |
| --------------------------------------- | ------------------------------------------------ |
| Required standard component unavailable | Identify equivalent LWC or custom implementation |
| External user experience limitations    | Validate guest and partner authentication early  |
| Performance issues                      | Conduct site performance testing                 |
| Missing template features               | Review LWR limitations before development        |

## 6. References

- Salesforce LWR Templates: https://developer.salesforce.com/docs/platform/exp-cloud-lwr/guide/template-overview.html
- LWR Template Limitations: https://developer.salesforce.com/docs/platform/exp-cloud-lwr/guide/template-limitations.html
- Experience Cloud Performance: https://help.salesforce.com/s/articleView?id=experience.exp_cloud_perf_considerations.htm
