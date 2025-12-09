"""Test cases cho Comic model"""
import pytest
from decimal import Decimal
from products.models import Comic


@pytest.mark.django_db
class TestComicModel:
    """Test suite cho Comic model"""

    def test_create_comic(self):
        """Test tạo comic mới với đầy đủ thông tin"""
        comic = Comic.objects.create(
            title="One Piece Vol.1",
            author="Eiichiro Oda",
            price=Decimal("50.00"),
            stock=100
        )
        assert comic.title == "One Piece Vol.1"
        assert comic.author == "Eiichiro Oda"
        assert comic.price == Decimal("50.00")
        assert comic.stock == 100
        assert comic.id is not None

    def test_comic_str_representation(self):
        """Test __str__ method trả về title"""
        comic = Comic.objects.create(
            title="Naruto Vol.1",
            author="Masashi Kishimoto",
            price=Decimal("45.00"),
            stock=50
        )
        assert str(comic) == "Naruto Vol.1"

    def test_comic_price_decimal_places(self):
        """Test price field có 2 chữ số thập phân"""
        comic = Comic.objects.create(
            title="Dragon Ball",
            author="Akira Toriyama",
            price=Decimal("39.99"),
            stock=75
        )
        assert comic.price == Decimal("39.99")

    def test_comic_without_image(self):
        """Test tạo comic không có image (blank=True, null=True)"""
        comic = Comic.objects.create(
            title="Bleach",
            author="Tite Kubo",
            price=Decimal("42.50"),
            stock=30
        )
        assert comic.image.name == ""

    def test_comic_update(self):
        """Test cập nhật thông tin comic"""
        comic = Comic.objects.create(
            title="Attack on Titan",
            author="Hajime Isayama",
            price=Decimal("55.00"),
            stock=20
        )
        comic.stock = 15
        comic.price = Decimal("49.99")
        comic.save()
        
        updated_comic = Comic.objects.get(id=comic.id)
        assert updated_comic.stock == 15
        assert updated_comic.price == Decimal("49.99")

    def test_comic_delete(self):
        """Test xóa comic"""
        comic = Comic.objects.create(
            title="Death Note",
            author="Tsugumi Ohba",
            price=Decimal("40.00"),
            stock=60
        )
        comic_id = comic.id
        comic.delete()
        
        assert not Comic.objects.filter(id=comic_id).exists()

    def test_comic_query_all(self):
        """Test query tất cả comics"""
        Comic.objects.create(
            title="Comic 1",
            author="Author 1",
            price=Decimal("10.00"),
            stock=10
        )
        Comic.objects.create(
            title="Comic 2",
            author="Author 2",
            price=Decimal("20.00"),
            stock=20
        )
        
        comics = Comic.objects.all()
        assert comics.count() == 2

    def test_comic_filter_by_author(self):
        """Test filter comics theo author"""
        Comic.objects.create(
            title="Comic A",
            author="Author X",
            price=Decimal("15.00"),
            stock=5
        )
        Comic.objects.create(
            title="Comic B",
            author="Author X",
            price=Decimal("25.00"),
            stock=10
        )
        Comic.objects.create(
            title="Comic C",
            author="Author Y",
            price=Decimal("35.00"),
            stock=15
        )
        
        comics_by_author_x = Comic.objects.filter(author="Author X")
        assert comics_by_author_x.count() == 2

    def test_comic_stock_zero(self):
        """Test tạo comic với stock = 0"""
        comic = Comic.objects.create(
            title="Out of Stock Comic",
            author="Test Author",
            price=Decimal("30.00"),
            stock=0
        )
        assert comic.stock == 0

    def test_comic_max_title_length(self):
        """Test title với độ dài tối đa (255 characters)"""
        long_title = "A" * 255
        comic = Comic.objects.create(
            title=long_title,
            author="Test Author",
            price=Decimal("25.00"),
            stock=5
        )
        assert len(comic.title) == 255
        assert comic.title == long_title
