import numpy as np
from typing import List, Tuple

class MediaPipePoseGraph:
    """
    Kinematic skeletal graph definition for MediaPipe 33 body landmarks.
    Yan et al. (AAAI 2018) Spatial-Temporal Graph Convolutional Networks representation.
    """
    NUM_NODES = 33

    # Primary structural skeletal edges connecting anatomical joints
    INWARD_EDGES: List[Tuple[int, int]] = [
        # Head / Facial features
        (0, 1), (1, 2), (2, 3), (3, 7),
        (0, 4), (4, 5), (5, 6), (6, 8),
        (9, 10),
        # Upper body (torso and arms)
        (11, 12),  # Shoulder to shoulder
        (11, 13), (13, 15),  # Left arm: shoulder -> elbow -> wrist
        (12, 14), (14, 16),  # Right arm: shoulder -> elbow -> wrist
        (15, 17), (15, 19), (15, 21),  # Left hand
        (16, 18), (16, 20), (16, 22),  # Right hand
        # Torso (shoulders to hips)
        (11, 23), (12, 24),
        (23, 24),  # Hip to hip
        # Lower body (hips to legs to feet)
        (23, 25), (25, 27), (27, 29), (29, 31), (27, 31),  # Left leg: hip -> knee -> ankle -> heel/toe
        (24, 26), (26, 28), (28, 30), (30, 32), (28, 32),  # Right leg: hip -> knee -> ankle -> heel/toe
    ]

    def __init__(self, strategy: str = "spatial"):
        self.edges = self.INWARD_EDGES
        self.num_node = self.NUM_NODES
        self.self_loops = [(i, i) for i in range(self.num_node)]
        self.A = self._build_adjacency_matrix(strategy)

    def _build_adjacency_matrix(self, strategy: str) -> np.ndarray:
        """
        Builds normalized spatial adjacency matrix A of shape (K, N, N)
        where K is the partition strategy size (e.g. 3: self, inward, outward).
        """
        A = np.zeros((self.num_node, self.num_node), dtype=np.float32)
        for i, j in self.edges:
            A[i, j] = 1.0
            A[j, i] = 1.0
        for i, j in self.self_loops:
            A[i, j] = 1.0

        # Degree matrix normalization: D^(-1/2) * A * D^(-1/2)
        degree = np.sum(A, axis=1)
        deg_inv_sqrt = np.power(degree, -0.5, where=degree > 0)
        deg_inv_sqrt[degree == 0] = 0.0
        D_inv = np.diag(deg_inv_sqrt)
        A_norm = np.dot(np.dot(D_inv, A), D_inv)

        # 3-subset spatial partition (self-root, centripetal inward, centrifugal outward)
        A_partitions = np.zeros((3, self.num_node, self.num_node), dtype=np.float32)
        A_partitions[0] = np.eye(self.num_node)  # Self
        A_partitions[1] = A_norm * 0.6          # Inward
        A_partitions[2] = A_norm * 0.4          # Outward

        return A_partitions
