import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Create sample data
data = {
    'x': range(1, 11),
    'y1': [2, 4, 5, 4, 5, 6, 7, 8, 9, 10],
    'y2': [1, 3, 4, 3, 4, 5, 6, 7, 8, 9]
}

# Create DataFrame
df = pd.DataFrame(data)

# Set style
plt.style.use('seaborn')

# Create figure with subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Line plot
df.plot(x='x', y=['y1', 'y2'], ax=ax1, marker='o')
ax1.set_title('Line Plot')
ax1.set_xlabel('X values')
ax1.set_ylabel('Y values')
ax1.grid(True)

# Scatter plot
ax2.scatter(df['x'], df['y1'], label='y1', alpha=0.6)
ax2.scatter(df['x'], df['y2'], label='y2', alpha=0.6)
ax2.set_title('Scatter Plot')
ax2.set_xlabel('X values')
ax2.set_ylabel('Y values')
ax2.legend()
ax2.grid(True)

# Adjust layout and save
plt.tight_layout()
plt.savefig('test_plots.png')
plt.close()

# Print some basic statistics
print("\nBasic Statistics:")
print(df.describe())

# Create correlation heatmap
plt.figure(figsize=(8, 6))
sns.heatmap(df.corr(), annot=True, cmap='coolwarm', center=0)
plt.title('Correlation Heatmap')
plt.savefig('correlation_heatmap.png')
plt.close() 