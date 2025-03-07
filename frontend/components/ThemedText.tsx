import { Text, type TextProps, StyleSheet, Platform } from 'react-native';
import { useThemeColor } from '@/hooks/useThemeColor';

export type ThemedTextProps = TextProps & {
  lightColor?: string;
  darkColor?: string;
  type?: 'default' | 'title' | 'defaultSemiBold' | 'subtitle' | 'link';
};

export function ThemedText({
  style,
  lightColor,
  darkColor,
  type = 'default',
  ...rest
}: ThemedTextProps) {
  const color = useThemeColor({ light: lightColor, dark: darkColor }, 'text');

  return (
    <Text
      style={[
        { color },
        type === 'default' && styles.default,
        type === 'title' && styles.title,
        type === 'defaultSemiBold' && styles.defaultSemiBold,
        type === 'subtitle' && styles.subtitle,
        type === 'link' && styles.link,
        style,
      ]}
      {...rest}
    />
  );
}

const styles = StyleSheet.create({
  default: {
    fontSize: Platform.OS === 'web' ? 16 : 11,
    lineHeight: Platform.OS === 'web' ? 24 : 11,
  },
  defaultSemiBold: {
    fontSize: Platform.OS === 'web' ? 16 : 11,
    lineHeight: Platform.OS === 'web' ? 21 : 11,
    fontWeight: '600',
  },
  title: {
    fontSize: Platform.OS === 'web' ? 32 : 20,
    fontWeight: 'bold',
    lineHeight: Platform.OS === 'web' ? 32 : 20,
  },
  subtitle: {
    fontSize: Platform.OS === 'web' ? 20 : 18,
    fontWeight: 'bold',
  },
  link: {
    lineHeight: Platform.OS === 'web' ? 30 : 14,
    fontSize: Platform.OS === 'web' ? 16 : 14,
    color: '#0a7ea4',
  },
});
