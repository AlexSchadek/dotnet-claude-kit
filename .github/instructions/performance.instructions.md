---
description: "Performance best practices for .NET: async patterns, caching, resource management, and hot-path optimizations."
applyTo: "**/*.cs"
---

# Performance Rules

## Async Patterns

- **Always propagate `CancellationToken` through the call chain.** Dropped tokens mean cancelled requests continue burning server resources.

```csharp
// DO
public Task<Order?> GetOrderAsync(Guid id, CancellationToken ct) =>
    db.Orders.FirstOrDefaultAsync(o => o.Id == id, ct);
```

- **Async all the way — no `.Result` or `.Wait()`.** Synchronously blocking on async causes thread pool starvation and deadlocks. Only acceptable in `Program.cs` top-level statements.

## Time and Clock

- **`TimeProvider` over `DateTime.Now` / `DateTime.UtcNow`.** `TimeProvider` is injectable and testable.

```csharp
// DO
public sealed class AuditService(TimeProvider clock)
{
    public DateTimeOffset Now => clock.GetUtcNow();
}
```

## Resource Management

- **`IHttpClientFactory` over `new HttpClient()`.** Direct instantiation causes socket exhaustion under load.
- **Use `ArrayPool<T>` / `MemoryPool<T>` for buffer-heavy operations.** Avoids GC pressure.

## Caching

- **`HybridCache` over `IMemoryCache` / `IDistributedCache`.** Provides stampede protection, L1+L2 caching, and tag-based invalidation out of the box.

```csharp
// DO
var order = await cache.GetOrCreateAsync(
    $"order:{id}",
    async ct => await db.Orders.FindAsync([id], ct),
    cancellationToken: ct);
```

## EF Core and Hot Paths

- **Use compiled queries for hot-path EF Core queries.**

```csharp
private static readonly Func<AppDbContext, Guid, CancellationToken, Task<Order?>> GetById =
    EF.CompileAsyncQuery((AppDbContext db, Guid id, CancellationToken ct) =>
        db.Orders.FirstOrDefault(o => o.Id == id));
```

- **Prefer `ValueTask<T>` over `Task<T>` for high-throughput paths that often complete synchronously.**
