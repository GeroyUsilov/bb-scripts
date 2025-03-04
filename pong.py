import pygame
import sys
import random

# Initialize pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 800, 600
PADDLE_WIDTH, PADDLE_HEIGHT = 15, 100
BALL_SIZE = 15
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
FPS = 60

# Create the screen
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Pong")
clock = pygame.time.Clock()

# Font for score display
font = pygame.font.Font(None, 74)

# Game objects
class Paddle:
    def __init__(self, x, y):
        self.rect = pygame.Rect(x, y, PADDLE_WIDTH, PADDLE_HEIGHT)
        self.speed = 7
        self.score = 0

    def move(self, up=True):
        if up:
            self.rect.y = max(0, self.rect.y - self.speed)
        else:
            self.rect.y = min(HEIGHT - PADDLE_HEIGHT, self.rect.y + self.speed)

    def draw(self):
        pygame.draw.rect(screen, WHITE, self.rect)

class Ball:
    def __init__(self):
        self.reset()

    def reset(self):
        self.rect = pygame.Rect(WIDTH // 2 - BALL_SIZE // 2, HEIGHT // 2 - BALL_SIZE // 2, BALL_SIZE, BALL_SIZE)
        # Random initial direction
        self.dx = random.choice([-1, 1]) * 5
        self.dy = random.choice([-1, 1]) * 5

    def update(self, left_paddle, right_paddle):
        self.rect.x += self.dx
        self.rect.y += self.dy

        # Top and bottom collisions
        if self.rect.top <= 0 or self.rect.bottom >= HEIGHT:
            self.dy *= -1

        # Score points
        if self.rect.left <= 0:
            right_paddle.score += 1
            self.reset()
        elif self.rect.right >= WIDTH:
            left_paddle.score += 1
            self.reset()

        # Paddle collisions
        if self.rect.colliderect(left_paddle.rect) and self.dx < 0:
            self.dx *= -1
            # Adjust angle based on where the ball hit the paddle
            relative_intersect_y = (left_paddle.rect.centery - self.rect.centery) / (PADDLE_HEIGHT / 2)
            self.dy = -relative_intersect_y * abs(self.dx)
        
        if self.rect.colliderect(right_paddle.rect) and self.dx > 0:
            self.dx *= -1
            # Adjust angle based on where the ball hit the paddle
            relative_intersect_y = (right_paddle.rect.centery - self.rect.centery) / (PADDLE_HEIGHT / 2)
            self.dy = -relative_intersect_y * abs(self.dx)

    def draw(self):
        pygame.draw.rect(screen, WHITE, self.rect)

# Create game objects
left_paddle = Paddle(20, HEIGHT // 2 - PADDLE_HEIGHT // 2)
right_paddle = Paddle(WIDTH - 20 - PADDLE_WIDTH, HEIGHT // 2 - PADDLE_HEIGHT // 2)
ball = Ball()

# Game loop
def main():
    running = True
    
    while running:
        # Handle events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False
        
        # Handle continuous key presses
        keys = pygame.key.get_pressed()
        if keys[pygame.K_w]:
            left_paddle.move(up=True)
        if keys[pygame.K_s]:
            left_paddle.move(up=False)
        if keys[pygame.K_UP]:
            right_paddle.move(up=True)
        if keys[pygame.K_DOWN]:
            right_paddle.move(up=False)
        
        # Simple AI for right paddle (uncomment to play against AI)
        """
        if ball.rect.centery < right_paddle.rect.centery:
            right_paddle.move(up=True)
        elif ball.rect.centery > right_paddle.rect.centery:
            right_paddle.move(up=False)
        """
        
        # Update ball
        ball.update(left_paddle, right_paddle)
        
        # Draw everything
        screen.fill(BLACK)
        
        # Draw center line
        for y in range(0, HEIGHT, 30):
            pygame.draw.rect(screen, WHITE, (WIDTH // 2 - 2, y, 4, 15))
        
        # Draw paddles and ball
        left_paddle.draw()
        right_paddle.draw()
        ball.draw()
        
        # Draw scores
        left_score = font.render(str(left_paddle.score), True, WHITE)
        right_score = font.render(str(right_paddle.score), True, WHITE)
        screen.blit(left_score, (WIDTH // 4, 20))
        screen.blit(right_score, (3 * WIDTH // 4, 20))
        
        # Refresh screen
        pygame.display.flip()
        clock.tick(FPS)
    
    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()