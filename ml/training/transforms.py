"""Shared deterministic preprocessing and training augmentations."""

from __future__ import annotations

from torchvision import transforms

from ml.training.constants import IMAGENET_MEAN, IMAGENET_STD, INPUT_IMAGE_SIZE


def build_train_transform(image_size: int = INPUT_IMAGE_SIZE) -> transforms.Compose:
    """Build training transform with moderate geometric and lighting augmentations."""
    return transforms.Compose(
        [
            transforms.RandomResizedCrop(image_size, scale=(0.75, 1.0)),
            transforms.RandomHorizontalFlip(p=0.5),
            transforms.RandomRotation(degrees=15),
            transforms.ColorJitter(brightness=0.15, contrast=0.15, saturation=0.15),
            transforms.ToTensor(),
            transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ]
    )


def build_eval_transform(image_size: int = INPUT_IMAGE_SIZE) -> transforms.Compose:
    """Build deterministic preprocessing shared by validation, test, and inference."""
    resize_size = int(round(image_size * 256 / 224))
    return transforms.Compose(
        [
            transforms.Resize(resize_size),
            transforms.CenterCrop(image_size),
            transforms.ToTensor(),
            transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ]
    )
