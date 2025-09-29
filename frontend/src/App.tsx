import React, { useState } from "react";

function App() {
  const [search, setSearch] = useState("");
  const [recipes, setRecipes] = useState<string[]>([]);

  // TODO: Load WASM parser, fetch recipes from GitHub, parse and display

  return (
    <div>
      <h1>Food Recipes</h1>
      <input
        type="text"
        placeholder="Search recipes..."
        value={search}
        onChange={e => setSearch(e.target.value)}
      />
      <ul>
        {recipes.filter(r => r.includes(search)).map((r, i) => (
          <li key={i}>{r}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
