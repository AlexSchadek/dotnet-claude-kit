---
description: "Modern C# 14 coding conventions, naming standards, and file organization for all .NET code."
applyTo: "**/*.cs"
---

# C# Coding Style

## File Organization

- **File-scoped namespaces always.** Block-scoped namespaces waste indentation for zero benefit.
- **One type per file.** File name must match the type name exactly (`OrderService.cs` contains `OrderService`).
- **Order members:** constants, fields, constructors, properties, public methods, private methods. Consistent ordering reduces cognitive load when scanning a file.

## Type Declarations

- **Primary constructors for DI injection.** Eliminates boilerplate field assignments and `_field = field` ceremony.

```csharp
// DO
public sealed class OrderService(IDbContext db, TimeProvider clock) { }

// DON'T
public class OrderService
{
    private readonly IDbContext _db;
    public OrderService(IDbContext db) { _db = db; }
}
```

- **Records for DTOs and value objects.** Immutability, value equality, and `with` expressions for free.

```csharp
public sealed record CreateOrderRequest(string ProductId, int Quantity);
public sealed record Money(decimal Amount, string Currency);
```

- **`sealed` on classes not designed for inheritance.** The JIT can devirtualize calls on sealed types, and it communicates intent clearly.
- **`internal` by default, `public` only when needed.** Minimize the public API surface.

## Expressions and Patterns

- **Collection expressions over constructor calls.**

```csharp
// DO
List<int> ids = [1, 2, 3];
int[] arr = [4, 5, 6];

// DON'T
var ids = new List<int> { 1, 2, 3 };
```

- **Pattern matching over if-else chains.** Switch expressions and `is` patterns are more readable and exhaustiveness-checked.

```csharp
// DO
var label = status switch
{
    OrderStatus.Pending => "Awaiting payment",
    OrderStatus.Shipped => "On the way",
    _ => "Unknown"
};
```

## Naming and Modifiers

- **`var` for obvious types, explicit types when clarity matters.**
- **Async suffix on all async methods.** `GetOrderAsync`, not `GetOrder`, for methods returning `Task` or `ValueTask`.
- **PascalCase** for public members, types, namespaces, methods. **camelCase** for locals and parameters.
- **No `_` prefix on private fields when using primary constructors.** The parameter name is the field name.
