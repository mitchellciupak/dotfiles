# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```rust
   // Testable
   fn process_order(order: Order, payment_gateway: &dyn PaymentGateway) {}

   // Hard to test
   fn process_order(order: Order) {
       let gateway = StripeGateway::new();
   }
   ```

2. **Return results, don't produce side effects**

   ```rust
   // Testable
   fn calculate_discount(cart: &Cart) -> Discount {}

   // Hard to test
   fn apply_discount(cart: &mut Cart) {
       cart.total -= discount;
   }
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup