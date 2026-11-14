"""Shared deterministic preprocessing and training augmentations."""

from __future__ import annotations

from typing import Literal

from torchvision import transforms

from ml.training.constants import IMAGENET_MEAN, IMAGENET_STD, INPUT_IMAGE_SIZE

AugmentationProfile = Literal["baseline", "camera_robust"]
SUPPORTED_PROFILES: tuple[str, ...] = ("baseline", "camera_robust")


def build_train_transform(
    image_size: int = INPUT_IMAGE_SIZE,
    profile: AugmentationProfile = "baseline",
) -> transforms.Compose:
    """Build training transforms for baseline studio or camera-robust real-world profiles."""
    if profile == "baseline":
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
    if profile == "camera_robust":
        # Stronger geometric, lighting, blur, and occlusion jitter to narrow camera domain shift.
        return transforms.Compose(
            [
                transforms.RandomResizedCrop(
                    image_size,
                    scale=(0.45, 1.0),
                    ratio=(0.75, 1.33),
                ),
                transforms.RandomHorizontalFlip(p=0.5),
                transforms.RandomPerspective(distortion_scale=0.25, p=0.4),
                transforms.RandomAffine(degrees=25, translate=(0.08, 0.08), shear=10),
                transforms.ColorJitter(
                    brightness=0.3,
                    contrast=0.3,
                    saturation=0.3,
                    hue=0.05,
                ),
                transforms.RandomApply(
                    [transforms.GaussianBlur(kernel_size=3, sigma=(0.1, 1.2))],
                    p=0.2,
                ),
                transforms.ToTensor(),
                transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
                transforms.RandomErasing(p=0.25, scale=(0.02, 0.14)),
            ]
        )
    raise ValueError(
        f"Unsupported augmentation profile '{profile}'. Expected one of {SUPPORTED_PROFILES}."
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
