from mesa import Model
from mesa.space import ContinuousSpace
from agents import MazeAgent

class MazeModel(Model):
    def __init__(self, N, width, height):
        super().__init__()
        self.num_agents = N
        self.width = width
        self.height = height
        self.space = ContinuousSpace(width, height, torus=False)

        # Walls
        self.walls = set()
        for x in range(width + 1):
            self.walls.add((x, 0))
            self.walls.add((x, height))
        for y in range(height + 1):
            self.walls.add((0, y))
            self.walls.add((width, y))
        for y in range(3, height-3):
            self.walls.add((width // 2, y))

        # Create agents
        self.agent_list = []  # <--- use a custom name
        for i in range(self.num_agents):
            agent = MazeAgent(i, self)
            self.agent_list.append(agent)
            while True:
                x = self.random.uniform(1, width-1)
                y = self.random.uniform(1, height-1)
                if (int(x), int(y)) not in self.walls:
                    break
            self.space.place_agent(agent, (x, y))

    def step(self):
        # Shuffle agents and call their step method
        self.agent_list.shuffle_do("step")
