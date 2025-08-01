## 销毁投掷物的魔法
extends Magic

func apply_on(enemy: Node2D):
    if enemy is Bullet:
        enemy.die()
