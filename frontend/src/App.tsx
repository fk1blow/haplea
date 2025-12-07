const recipe = {
  title: "Shoyu Ramen",
  description: "Rich Japanese noodle soup with savory soy-based broth.",
  category: "soups",
  tags: ["japanese", "noodles", "comfort-food", "umami", "winter"],
  ingredients: [
    "1kg chicken bones (for broth)",
    "8 cups water",
    "2 packs fresh ramen noodles",
    "300g pork belly, sliced",
    "2 large eggs",
    "2 green onions, sliced",
    "2 sheets nori (dried seaweed)",
    "3 tbsp soy sauce",
    "1 tbsp mirin",
    "1 tsp sesame oil (optional)",
    "Salt to taste",
  ],
  instructions:
    "Prepare the broth by simmering chicken bones for 4 hours. Cook noodles separately according to package instructions. Slice pork belly and sear until crispy. Soft boil eggs for 6 minutes. Assemble bowls with noodles, pour hot broth over, top with pork, egg, green onions, and nori.",
  notes:
    "The broth can be made in advance and frozen. Add a dash of sesame oil for extra richness.",
};

function App() {
  return (
    <div className="min-h-screen bg-dark-bg">
      {/* Header */}
      <header className="border-b border-dark-border">
        <div className="max-w-3xl mx-auto px-6 py-4">
          <h1 className="text-lg font-semibold text-dark-text tracking-tight">
            haplea
          </h1>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-3xl mx-auto px-6 py-12">
        {/* Recipe header */}
        <div className="mb-8">
          <span className="text-xs font-medium text-accent uppercase tracking-wider">
            {recipe.category}
          </span>
          <h2 className="mt-2 text-4xl font-bold text-dark-text tracking-tight">
            {recipe.title}
          </h2>
          <p className="mt-3 text-lg text-dark-text-secondary leading-relaxed">
            {recipe.description}
          </p>

          {/* Tags */}
          <div className="mt-4 flex flex-wrap gap-2">
            {recipe.tags.map((tag) => (
              <span key={tag} className="tag">
                {tag}
              </span>
            ))}
          </div>
        </div>

        {/* Recipe content grid */}
        <div className="grid gap-8 md:grid-cols-[1fr,2fr]">
          {/* Ingredients */}
          <section className="recipe-card">
            <h3 className="text-sm font-semibold text-dark-text uppercase tracking-wider mb-4">
              Ingredients
            </h3>
            <ul className="space-y-0">
              {recipe.ingredients.map((ingredient, index) => (
                <li key={index} className="ingredient-item">
                  <span className="w-1.5 h-1.5 mt-2 rounded-full bg-dark-muted flex-shrink-0" />
                  <span className="text-dark-text-secondary">{ingredient}</span>
                </li>
              ))}
            </ul>
          </section>

          {/* Instructions */}
          <section className="recipe-card">
            <h3 className="text-sm font-semibold text-dark-text uppercase tracking-wider mb-4">
              Instructions
            </h3>
            <p className="text-dark-text-secondary leading-relaxed">
              {recipe.instructions}
            </p>

            {/* Notes */}
            {recipe.notes && (
              <div className="mt-6 pt-6 border-t border-dark-border">
                <h4 className="text-xs font-semibold text-dark-muted uppercase tracking-wider mb-2">
                  Notes
                </h4>
                <p className="text-sm text-dark-text-secondary italic">
                  {recipe.notes}
                </p>
              </div>
            )}
          </section>
        </div>
      </main>
    </div>
  );
}

export default App;
