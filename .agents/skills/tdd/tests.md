# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```rust
// GOOD: Tests observable behavior
#[tokio::test]
async fn user_can_checkout_with_valid_cart() {
    let mut cart = create_cart();
    cart.add(product);
    let result = checkout(cart, payment_method).await;
    assert_eq!(result.status, "confirmed");
}
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```rust
// BAD: Tests implementation details
#[tokio::test]
async fn checkout_calls_payment_service_process() {
    let mock_payment = MockPaymentService::new();
    checkout(cart, &mock_payment).await;
    mock_payment.assert_process_called_with(cart.total);
}
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```rust
// BAD: Bypasses interface to verify
#[tokio::test]
async fn create_user_saves_to_database() {
    create_user(User { name: "Alice".into() }).await;
    let row = db.query("SELECT * FROM users WHERE name = $1", &["Alice"]).await;
    assert!(row.is_some());
}

// GOOD: Verifies through interface
#[tokio::test]
async fn create_user_makes_user_retrievable() {
    let user = create_user(User { name: "Alice".into() }).await;
    let retrieved = get_user(user.id).await;
    assert_eq!(retrieved.name, "Alice");
}
```