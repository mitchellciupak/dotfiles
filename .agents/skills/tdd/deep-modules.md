# Deep Modules

From "A Philosophy of Software Design":

**Deep module** = small interface (few methods and simple params) + deep implementation. keeping complex logic hidden 


**Shallow module** = large interface (Many methods and complex params) + little implementation (avoid). This makes the interface not much more than a pass through

When designing interfaces, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?