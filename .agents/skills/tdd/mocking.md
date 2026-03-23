# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```rust
// Easy to mock
fn process_payment(order: &Order, payment_client: &dyn PaymentClient) -> Result<Receipt> {
    payment_client.charge(order.total)
}

// Hard to mock
fn process_payment(order: &Order) -> Result<Receipt> {
    let client = StripeClient::new(&std::env::var("STRIPE_KEY").unwrap());
    client.charge(order.total)
}
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

```rust
// GOOD: Each function is independently mockable
trait Api {
    fn get_user(&self, id: UserId) -> Result<User>;
    fn get_orders(&self, user_id: UserId) -> Result<Vec<Order>>;
    fn create_order(&self, data: OrderData) -> Result<Order>;
}

// BAD: Mocking requires conditional logic inside the mock
trait Api {
    fn fetch(&self, endpoint: &str, options: FetchOptions) -> Result<Response>;
}
```

The SDK approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint