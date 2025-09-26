import solara
import asyncio
import io
import numpy as np
from model import MazeModel
from matplotlib.patches import Rectangle, Circle
import matplotlib.pyplot as plt
from PIL import Image as PILImage

# Initialize the model
model = MazeModel(N=5, width=20, height=20)

# Reactive step counter
step_counter = solara.reactive(0)

# Async loop to update agents
async def step_loop():
    while True:
        model.step()
        step_counter.value += 1
        await asyncio.sleep(1)

@solara.component
def MazeVisualization():
    solara.use_effect(lambda: asyncio.create_task(step_loop()), [])

    # Create figure
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.set_xlim(0, model.width)
    ax.set_ylim(0, model.height)
    ax.set_aspect('equal')
    ax.grid(True, color='lightgray')

    # Draw walls
    for (x, y) in model.walls:
        rect = Rectangle((x, y), 1, 1, color='black')
        ax.add_patch(rect)

    # Draw agents
    for agent in model.agent_list:
        x, y = agent.pos
        circ = Circle((x, y), 0.4, color='blue')
        ax.add_patch(circ)

    ax.invert_yaxis()

    # Convert Matplotlib figure to image
    buf = io.BytesIO()
    fig.savefig(buf, format='png')
    buf.seek(0)
    img = PILImage.open(buf)
    img_array = np.array(img)

    return solara.Image(img_array)

@solara.component
def App():
    solara.Markdown("# Maze Model with Agents")
    MazeVisualization()
    solara.Markdown(f"Step: {step_counter.value}")

app = App
