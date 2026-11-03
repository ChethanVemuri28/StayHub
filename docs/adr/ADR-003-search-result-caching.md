# ADR-003: Caching Hotel Search Results

**Status:** Proposed  
**Date:** November 3, 2026  
**Decision Area:** Search Performance and Caching

## 1. Context

StayHub allows public visitors and registered guests to search for hotels and available rooms.

Search operations may involve:
- Retrieving active hotels.
- Retrieving room types and amenities.
- Filtering by location.
- Filtering by occupancy.
- Checking room availability for selected dates.
- Retrieving room prices.

Repeated searches can increase database queries and server processing.

The system needs a caching strategy that improves search performance without returning incorrect room availability or outdated booking information.

## 2. Options

### Option A: No Application-Level Caching

Execute database queries for every search request.

Advantages:
- Always retrieves current database information.
- Simple implementation.
- No cache invalidation requirements.

Disadvantages:
- Repeated database queries.
- Increased server processing.
- Potential performance degradation with higher traffic.

### Option B: Client-Side Caching

Use Lightning Data Service, client-side caching and cacheable Apex methods where appropriate.

Advantages:
- Reduces repeated server requests.
- Improves responsiveness.
- Suitable for data that does not change frequently.
- Requires less server-side cache management.

Disadvantages:
- Cached data can become outdated.
- Cache lifetime and refresh behavior must be considered.
- Not suitable as the sole mechanism for validating room availability.

### Option C: Salesforce Platform Cache

Use Salesforce Platform Cache to store frequently accessed search results.

Two caching scopes are available:

**Org Cache**
- Shared across users and sessions.
- Suitable for commonly reused public catalogue data.

**Session Cache**
- Limited to an individual user session.
- Suitable for session-specific search information.

Advantages:
- Reduces repeated SOQL queries.
- Supports shared or session-specific caching.
- Provides configurable expiration.
- Can improve performance for frequently accessed data.

Disadvantages:
- Requires Platform Cache configuration and available capacity.
- Cached entries can expire or be evicted.
- Requires cache-key management and invalidation.
- Cached values are temporary and not guaranteed to persist.

## 3. Decision

**StayHub will use a layered caching strategy.**

### Public Hotel and Room Catalogue

Use client-side caching and, where appropriate, Salesforce LWR/CDN caching for publicly accessible content.

Use Org Platform Cache for frequently reused hotel catalogue and room-type search results if capacity is available.

### Search Filters

Search results will use cache keys derived from normalized search parameters, such as:

- Location.
- Check-in date.
- Check-out date.
- Guest count.
- Room count.
- Search filters.

Different search criteria must not return results from an unrelated cache entry.

### Room Availability

Room availability is dynamic and can change when another guest completes a booking.

Therefore:

- Availability results may be cached only briefly if justified by performance testing.
- Cached availability must never be treated as confirmation of a booking.
- The booking service must revalidate availability against current records before confirming a booking.

### Cache Invalidation

Cached catalogue information must be refreshed or invalidated when relevant hotel or room configuration records change.

Cache misses must fall back to the database.

## 4. Reasons

1. Hotel catalogue information is relatively stable compared with room availability.
2. Repeated catalogue searches can benefit from caching.
3. Caching reduces unnecessary database queries.
4. LWR supports HTTP caching for eligible public resources and public data.
5. Platform Cache provides reusable session and organization-level caching.
6. Booking availability must remain accurate to prevent overlapping bookings.
7. A layered strategy allows different data types to use different caching policies.

## 5. Consequences

### Positive Consequences

- Reduced repeated database queries.
- Improved hotel search responsiveness.
- Better performance for frequently accessed catalogue information.
- Flexible caching based on data type.
- Reduced unnecessary processing.

### Negative Consequences

- Additional implementation complexity.
- Cache invalidation must be maintained.
- Expired or evicted entries require database fallback.
- Platform Cache capacity and availability may affect implementation.
- Search results may occasionally display slightly outdated catalogue information until refresh.

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Stale hotel information | Configure suitable TTL and invalidate affected entries |
| Stale room availability | Revalidate availability before booking |
| Incorrect cache key | Include all relevant normalized search parameters |
| Cache eviction | Implement database fallback |
| Sensitive information exposure | Cache only approved public catalogue data in shared public caches |
| Insufficient cache capacity | Monitor usage and evaluate cache allocation |

## 6. Initial Caching Policy

The following are proposed starting values and must be tuned through performance testing.

| Data Type | Cache Strategy | Initial TTL |
|---|---|---|
| Public hotel catalogue | Org Cache / public HTTP caching | 15 minutes |
| Room types and amenities | Org Cache / client-side caching | 15 minutes |
| Public hotel search results | Org Cache | 2 minutes |
| Room availability search results | No shared cache initially | No cache |
| Booking records | No shared cache | No cache |
| Payment records | No shared cache | No cache |

The initial TTL values are design choices, not Salesforce platform defaults.

## 7. References

- Salesforce Platform Cache: https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-platform-cache-features.html
- Platform Cache Best Practices: https://trailhead.salesforce.com/content/learn/modules/platform_cache/platform_cache_use
- Platform Cache Considerations: https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-platform-cache-limitations.html
- LWR Caching Policy: https://developer.salesforce.com/docs/platform/exp-cloud-lwr/guide/template-differences-caching.html

