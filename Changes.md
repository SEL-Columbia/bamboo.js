v 0.2
===============
- Moved api functions to main bamboo namespace
- Re-structured Dataset object function to use the main functions but work similarly to how they did before
- Updated Dataset.join to only take a right hand side dataset id and use its own id as the left hand side dataset
- bamboo.dataset_exists now runs asynchronously by default, pass in false to the async arg to run synchronously