from mesa import Agent

class MazeAgent(Agent):
    def __init__(self, unique_id, model):
        # Pass the model to the base Agent
        super().__init__(model)
        self.unique_id = unique_id  # store manually
        self.pos = None

    def step(self):
        x, y = self.pos
        dx, dy = self.model.random.uniform(-1, 1), self.model.random.uniform(-1, 1)
        new_x, new_y = x + dx, y + dy

        # Check walls and boundaries
        if 0 <= new_x <= self.model.width and 0 <= new_y <= self.model.height:
            if (int(new_x), int(new_y)) not in self.model.walls:
                self.model.space.move_agent(self, (new_x, new_y))
