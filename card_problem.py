# Example cards:
# {2: [1, 3], 4: [2]} -> 1 1 2 2 2 2 3 3

# TODO:
# - Use linked list to optimise insertion
# - Can we store changes only rather than whole hand

from fractions import Fraction

class Node:

    def __init__(self, dag, cards):
        self.dag = dag
        self.parents = None
        self.children = None
        self.cards = cards
        self.value = self.compute_value(cards)

    @staticmethod
    def create_relation(parent, child):
        if parent not in child.parents:
            child.parents.append(parent)
        if child not in parent.children:
            parent.children.append(child)

    @staticmethod
    def compute_value(cards):
        best = 0
        tot = 0
        for count, numbers in cards.items():
            tot += count * len(numbers)
            best = max(best, count * numbers[-1])
        return Fraction(best, tot)
    
    @property
    def size(self):
        return sum(count * len(numbers) for count, numbers in self.cards.items())

    def add_children(self):

        for count, numbers in self.cards.items():

            new_cards = self.cards.copy()
            n = new_cards[count].pop(0)
            new_cards[count + 1] = [n, *new_cards[count + 1]]
            new = Node(new_cards)


class DAG:

    def __init__(self, root):
        self.root = root
        self.levels = [[root]]



    def add_level(self):
        for node in self.levels[-1]:
            node.add_children()



if __name__ == "__main__":
    node = Node({1: [2, 3], 2: [1]})  # 1 1 2 3 -> 3 / 4
    print(node.value)

    # 1 1 2 2 2 

    root = Node({1: [1]})


# Questions to answer:
# Does the greedy dag have the same optima as the whole DAG? (Is the greedy strategy optimal on/off-policy?)
# 
# 

# Things we need:
# - Plot the DAG
# - Build the DAG up to level k
# - To know whether greedy DAG has same optima as whole DAG
# - Get the optimal value and cards for level k
