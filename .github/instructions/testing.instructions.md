---
description: "Testing strategy, patterns, and naming conventions for .NET projects using xUnit v3, WebApplicationFactory, and Testcontainers."
applyTo: "**/*Tests/**/*.cs"
---

# Testing Rules

## Strategy

- **Integration tests first.** Use `WebApplicationFactory` + Testcontainers to test real HTTP pipelines against real databases. Integration tests catch the bugs that unit tests miss — serialization, middleware, DI wiring, query behavior.
- **No in-memory database for testing.** `UseInMemoryDatabase` has different behavior from real providers (no constraints, no transactions, no SQL translation). Use Testcontainers for the real engine.

```csharp
// DO — real PostgreSQL via Testcontainers
public sealed class DatabaseFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container = new PostgreSqlBuilder().Build();
    public string ConnectionString => _container.GetConnectionString();
    public Task InitializeAsync() => _container.StartAsync();
    public Task DisposeAsync() => _container.DisposeAsync().AsTask();
}
```

## Test Structure

- **AAA pattern with clear separation.** Arrange, Act, Assert separated by blank lines.

```csharp
[Fact]
public async Task CreateOrder_ValidRequest_ReturnsCreated()
{
    // Arrange
    var client = _factory.CreateClient();
    var request = new CreateOrderRequest("SKU-1", Quantity: 2);

    // Act
    var response = await client.PostAsJsonAsync("/orders", request);

    // Assert
    response.StatusCode.Should().Be(HttpStatusCode.Created);
}
```

- **One assertion concept per test.** Multiple property assertions on one result are fine; testing two separate behaviors in one test is not.

## Naming

- **`MethodName_Scenario_ExpectedResult`.** Clear, searchable, self-documenting.

```
GetOrderAsync_OrderDoesNotExist_ReturnsNull
CreateOrder_DuplicateSku_ThrowsConflictException
```

## Fixtures and Mocking

- **Shared fixtures for expensive setup.** Database containers, HTTP servers, and message brokers should be shared via `IClassFixture<T>` or `ICollectionFixture<T>`.
- **No mocking frameworks for things you own.** If you control the code, use a real or test implementation. Mocking your own interfaces couples tests to implementation details.

## Behavior Over Implementation

- **Test behavior, not implementation details.** Assert on observable outcomes (HTTP response, database state, published event), not on which internal methods were called.
