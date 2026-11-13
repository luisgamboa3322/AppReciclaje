"""PyTorch backbone builders for PECOX Vision waste material classification."""

from __future__ import annotations

import torch.nn as nn
from torchvision import models

from ml.training.constants import CANONICAL_CLASSES

SUPPORTED_ARCHITECTURES = ("resnet18", "mobilenet_v3_small")


def build_classifier(
    architecture: str = "resnet18",
    num_classes: int = len(CANONICAL_CLASSES),
    pretrained: bool = True,
    dropout: float = 0.2,
) -> nn.Module:
    """Instantiate a classification model with a PECOX classification head."""
    if architecture == "resnet18":
        weights = models.ResNet18_Weights.DEFAULT if pretrained else None
        model = models.resnet18(weights=weights)
        in_features = model.fc.in_features
        model.fc = nn.Sequential(
            nn.Dropout(p=dropout),
            nn.Linear(in_features, num_classes),
        )
        return model

    if architecture == "mobilenet_v3_small":
        weights = models.MobileNet_V3_Small_Weights.DEFAULT if pretrained else None
        model = models.mobilenet_v3_small(weights=weights)
        in_features = model.classifier[-1].in_features
        model.classifier[-1] = nn.Linear(in_features, num_classes)
        return model

    raise ValueError(
        f"Unsupported architecture '{architecture}'. Supported: {SUPPORTED_ARCHITECTURES}"
    )
