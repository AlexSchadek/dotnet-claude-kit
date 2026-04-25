---
description: "Dependency direction, feature organization, and module boundary rules for .NET solution architecture."
applyTo: "**/*.cs"
---

# Architecture Rules

## Ask First, Recommend Second

- **Never assume an architecture — use the architecture-advisor skill.** Every project has different constraints. Ask about team size, domain complexity, and deployment model before recommending Clean Architecture, VSA, DDD, or Modular Monolith.

## Data Access

- **No repository pattern over EF Core.** `DbContext` is already a Unit of Work + Repository. Wrapping it adds indirection with no value.

```csharp
// DO — inject DbContext directly
public sealed class OrderService(AppDbContext db)
{
    public Task<Order?> GetAsync(Guid id, CancellationToken ct) =>
        db.Orders.FindAsync([id], ct).AsTask();
}

// DON'T — generic repository wrapping EF
public interface IRepository<T> { Task<T?> GetByIdAsync(Guid id); }
```

## Endpoint Organization

- **Every endpoint group gets its own file implementing `IEndpointGroup`.** Never define endpoints inline in `Program.cs`.
- **Use `app.MapEndpoints()` for auto-discovery.** Program.cs calls `app.MapEndpoints()` once. Scans the assembly for all `IEndpointGroup` implementations. Program.cs never changes when adding endpoints.
- **Never add `MapGroup` or `Map*Endpoints()` calls to Program.cs.** Both inline endpoints and manual extension-method wiring are anti-patterns.

```csharp
// DO — auto-discovered endpoint group
public sealed class OrderEndpoints : IEndpointGroup
{
    public void Map(IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/orders").WithTags("Orders");
        group.MapGet("/", ListOrders);
        group.MapPost("/", CreateOrder);
    }
}
```

## Project Organization

- **Feature folders over layer folders.** Vertical slices keep related code together.

```
# DO                          # DON'T
Features/                     Controllers/
  Orders/                       OrdersController.cs
    CreateOrder.cs              GetOrder.cs
    OrderEndpoints.cs         Services/
  Products/                     OrderService.cs
```

- **Dependency direction is inward.** Domain depends on nothing. Application depends on Domain. Infrastructure depends on Application. Presentation depends on Application.
- **Module boundaries enforced through project references.** Use integration events or a shared contracts project for cross-module communication.

## Shared Kernel

- **Shared kernel contains only contracts, never business logic.** Interfaces, DTOs, integration event definitions. Domain logic belongs in the owning module.
