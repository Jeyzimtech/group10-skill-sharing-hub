from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .serializers import RegisterSerializer, LoginSerializer, ForgotPasswordSerializer


def _token_response(user):
    refresh = RefreshToken.for_user(user)
    return {
        'token': str(refresh.access_token),
        'refresh': str(refresh),
        'user': {'id': user.id, 'name': user.name, 'email': user.email},
    }


@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response(_token_response(user), status=status.HTTP_201_CREATED)
    first_error = next(iter(serializer.errors.values()))[0]
    status_code = status.HTTP_409_CONFLICT if 'already exists' in str(first_error) else status.HTTP_400_BAD_REQUEST
    return Response({'message': str(first_error)}, status=status_code)


@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        return Response(_token_response(serializer.validated_data['user']))
    first_error = next(iter(serializer.errors.values()))[0]
    return Response({'message': str(first_error)}, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    serializer = ForgotPasswordSerializer(data=request.data)
    if not serializer.is_valid():
        return Response({'message': 'Invalid email.'}, status=status.HTTP_400_BAD_REQUEST)
    email = serializer.validated_data['email']
    if User.objects.filter(email=email).exists():
        pass  # TODO: send actual reset email
    return Response({'message': 'If this email exists, reset instructions have been sent.'})
